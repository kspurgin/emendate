# frozen_string_literal: true

require "strscan"

require "emendate/date_utils"
require "emendate/location"

module Emendate
  class Lexer
    include Dry::Monads[:result]
    include Dry::Monads::Do.for(:call)
    include DateUtils

    class << self
      def call(...)
        new(...).call
      end
    end

    SINGLES = {
      "'" => :apostrophe,
      ":" => :colon,
      "," => :comma,
      "{" => :curly_bracket_open,
      "}" => :curly_bracket_close,
      "(" => :parenthesis_open,
      ")" => :parenthesis_close,
      "%" => :percent,
      "+" => :plus,
      "?" => :question,
      "/" => :slash,
      " " => :space,
      "[" => :square_bracket_open,
      "]" => :square_bracket_close,
      "~" => :tilde
    }
    ["\u002D", "\u2010", "\u2011", "\u2012", "\u2013", "\u2014", "\u2015",
      "\u2043"].each { |val| SINGLES[val] = :hyphen }
    SINGLES.freeze

    ORDINAL_INDICATORS = %w[st nd rd th d].freeze

    days = "^(" + ([
      Date::DAYNAMES.compact,
      Date::ABBR_DAYNAMES.compact.map { |val| val + '\.?' }
    ].flatten
      .join("|") + ")")
    months = "^(" + ([
      Date::MONTHNAMES.compact,
      Date::ABBR_MONTHNAMES.compact.map { |val| val + '\.?' },
      'Sept\.?'
    ].flatten
                       .join("|") + ")")
    ordinals = "^(" + ORDINAL_INDICATORS.join("|") + ")"

    ALPHA = {
      /^(about|around)/i => :about,
      /^(after|post)/i => :after,
      /^(&|and)/i => :and,
      /^(probably|probable|prob\.)/i => :probably,
      /^(possibly|possible|poss\.)/i => :possibly,
      /^(approximate(ly|)|estimated?|est\.?)/i => :approximate,
      /^present/i => :present,
      /^(before|pre|prior to)/i => :before,
      /^(century|cent\.?)/i => :century,
      /^(ca\.?|circa)/i => :circa,
      Regexp.new(days, "i") => :day_of_week_alpha,
      /^(b\.? ?c\.? ?e\.?|b\.? ?p\.?|b\.? ?c\.?)/i => :era_bce,
      /^(c\.? ?e\.?|a\.? ?d\.?)/i => :era_ce,
      /^early/i => :early,
      /^(middle|mid)/i => :mid,
      /^late/i => :late,
      Regexp.new(months, "i") => :month_alpha,
      /^or/i => :or,
      /^to/i => :range_indicator,
      # If additional alphabetic seasons are added, make sure to
      #   update the mapping to literals in Segments::SeasonAlpha
      /^(winter|spring|summer|fall|autumn)/i => :season,
      /^(date\sunknown|unknown\sdate|no\sdate|not\sdated|undated|
      unknown|unk|n\.?\s?d\.?)$/ix => :unknown_date,
      Regexp.new(ordinals, "i") => :ordinal_indicator,
      /^(u+|x+)/i => :uncertainty_digits
    }

    SINGLE_ALPHA = /^[cestyz]$/i

    def initialize(tokens)
      if tokens.is_a?(String)
        @scanner = StringScanner.new(tokens)
        @tokens = Emendate::SegmentSets::TokenSet.new(string: tokens)
      else
        @tokens = tokens
        @scanner = StringScanner.new(tokens.orig_string)
      end
    end

    def call
      _tokenized = yield tokenize

      Success(tokens)
    end

    private

    attr_reader :tokens, :scanner

    def tokenize
      tokenize_anchored_start
      tokenization until scanner.eos?
    rescue => e
      Failure(e)
    else
      Success()
    end

    def tokenization
      nextchar = scanner.getch
      scanner.unscan

      token = if SINGLES.key?(nextchar)
        tokenize_single
      elsif nextchar == "."
        tokenize_dots
      elsif digit?(nextchar)
        tokenize_number
      elsif alpha?(nextchar)
        tokenize_letter(nextchar)
      end
      return if token

      init = scanner.pos
      match = scanner.getch
      add_token(match, :unknown, init)
    end

    def tokenize_anchored_start
      case scanner.string
      when /^c\.? ?[^a-z]/i then tokenize_starting_circa
      end
    end

    def tokenize_starting_circa
      init = scanner.pos
      match = scanner.scan(/^c\.? ?/i)
      add_token(match, :circa, init)
    end

    def tokenize_single
      init = scanner.pos
      match = scanner.getch
      add_token(match, SINGLES[match], init)
      true
    end

    def tokenize_dots
      init = scanner.pos
      match = scanner.scan(/\.+/)
      type = case match.length
      when 1
        :single_dot
      when 2
        :double_dot
      else
        :unknown
      end
      add_token(match, type, init)
      true
    end

    def tokenize_number
      init = scanner.pos
      match = scanner.scan(/\d+/)
      tokens << Number.new(
        type: :number, lexeme: match, location: location(init)
      )
      tokenize_ordinal_indicator
    end

    def tokenize_ordinal_indicator
      indicator = ORDINAL_INDICATORS.find { |ind| ordinal_val_match?(ind) }
      return true unless indicator

      init = scanner.pos
      pattern = Regexp.new(indicator, Regexp::IGNORECASE)
      match = scanner.scan(pattern)
      add_token(match, :ordinal_indicator, init)
      true
    end

    def ordinal_val_match?(str)
      chk = scanner.peek(str.length).downcase
      str.downcase == chk
    end

    def tokenize_letter(_char)
      pattern = alpha_matcher

      if pattern
        tokenize_alpha_pattern(pattern)
      elsif single_alpha?
        tokenize_single_alpha
      else
        tokenize_unknown_alpha
      end
      true
    end

    def alpha_matcher
      chk = scanner.rest
      ALPHA.keys.find { |regexp| regexp.match?(chk) }
    end

    def tokenize_alpha_pattern(pattern)
      init = scanner.pos
      match = scanner.scan(pattern)
      if alpha?(scanner.peek(1))
        addtl = scanner.scan(/[a-z]+/i)
        add_token(match + addtl, :unknown, init)
      else
        case ALPHA[pattern]
        when :month_alpha
          tokens << Emendate::MonthAlpha.new(
            lexeme: match,
            type: :month_alpha,
            location: location(init)
          )
        when :season
          tokens << Emendate::SeasonAlpha.new(
            lexeme: match,
            type: :season,
            location: location(init)
          )
        when :early
          tokens << Emendate::Segment.new(
            lexeme: match,
            literal: :early,
            type: :partial
          )
        when :mid
          tokens << Emendate::Segment.new(
            lexeme: match,
            literal: :mid,
            type: :partial
          )
        when :late
          tokens << Emendate::Segment.new(
            lexeme: match,
            literal: :late,
            type: :partial
          )
        else
          add_token(match, ALPHA[pattern], init)
        end
      end
    end

    def single_alpha?
      scanner.rest.match?(/^[a-z]\b/i) ||
        scanner.rest.match?(/^[a-z]\d/i)
    end

    def tokenize_single_alpha
      init = scanner.pos
      char = scanner.scan(/./)
      type = :"letter_#{char.downcase}"
      add_token(char, type, init)
    end

    def tokenize_unknown_alpha
      init = scanner.pos
      match = scanner.scan(/[a-z]+/i)
      add_token(match, :unknown, init)
    end

    # @param lexeme [String]
    # @param type [Symbol]
    # @param init [Integer]
    def add_token(lexeme, type, init)
      tokens << Emendate::Segment.new(
        lexeme: lexeme, type: type, location: location(init)
      )
    end

    def location(startpos)
      length = scanner.pos - startpos
      Emendate::Location.new(startpos, length)
    end

    def digit?(char)
      char >= "0" && char <= "9"
    end

    def alpha?(char)
      /[a-z&]/i.match?(char)
    end
  end
end
