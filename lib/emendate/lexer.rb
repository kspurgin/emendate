# frozen_string_literal: true

require "strscan"

require "emendate/date_utils"

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
      "|" => :pipe,
      "\u{FF5C}" => :pipe,
      "%" => :percent,
      "+" => :plus,
      "?" => :question,
      "/" => :slash,
      " " => :space,
      "[" => :square_bracket_open,
      "]" => :square_bracket_close,
      "~" => :tilde,
      "©" => :copyright
    }
    SINGLES.freeze

    HYPHENS = ["\u002D", "\u2010", "\u2011", "\u2012", "\u2013", "\u2014",
      "\u2015", "\u2043"].freeze
    ORDINAL_INDICATORS = %w[st nd rd th d].freeze

    days = "^(" + ([
      Date::DAYNAMES.compact,
      Date::ABBR_DAYNAMES.compact.map { |val| val + '\.?' }
    ].flatten
      .join("|") + ")")
    months = "^(" + ([
      Date::MONTHNAMES.compact,
      'Sept\.?',
      Date::ABBR_MONTHNAMES.compact.map { |val| val + '\.?' }
    ].flatten.join("|") + ")")
    ordinals = "^(" + ORDINAL_INDICATORS.join("|") + ")"

    ALPHA = {
      /^(after|later|post)/i => :after,
      /^(&|and)/i => :and,
      /^(about|around|approximate(ly|)|ca\.?|circa|estimated?|est\.?)/i =>
        :approximate,
      /^(probably|probable|prob\.|possibly|possible|poss\.)/i => :uncertain,
      /^present/i => :present,
      /^(before|pre|prior to)/i => :before,
      /^(century|cent\.?)/i => :century,
      Regexp.new(days, "i") => :day_of_week_alpha,
      /^(b\.? ?c\.? ?e\.?|b\.? ?p\.?|b\.? ?c\.?)/i => :era_bce,
      /^(c\.? ?e\.?|a\.? ?d\.?)/i => :era_ce,
      /^early/i => :early,
      /^(middle|mid)/i => :mid,
      /^late/i => :late,
      Regexp.new(months, "i") => :month,
      /^or/i => :or,
      /^to/i => :range_indicator,
      # If additional alphabetic seasons are added, make sure to
      #   update the mapping to literals in Segments::SeasonAlpha
      /^(winter|spring|summer|fall|autumn)/i => :season,
      /^(date\sunknown|unknown\sdate|no\sdate|not\sdated|undated|
      unknown|unk|n\.?\s?d\.?)/ix => :unknown_date,
      Regexp.new(ordinals, "i") => :ordinal_indicator,
      /^(u+|x+)/i => :uncertainty_digits
    }

    SINGLE_ALPHA = /^[cestyz]$/i

    def initialize(tokens)
      if tokens.is_a?(String)
        @scanner = StringScanner.new(tokens)
        @tokens = Emendate::SegmentSet.new(string: tokens)
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
      elsif HYPHENS.include?(nextchar)
        tokenize_hyphens
      elsif digit?(nextchar)
        tokenize_number
      elsif alpha?(nextchar)
        tokenize_letter(nextchar)
      end
      return if token

      match = scanner.getch
      add_token(match, :unknown)
    end

    def tokenize_anchored_start
      case scanner.string
      when /^c\.? ?[^a-z]/i then tokenize_starting_c
      end
    end

    def tokenize_starting_c
      match = scanner.scan(/^c\.? ?/i)
      type = case Emendate.options.c_before_date
      when :circa then :approximate
      when :copyright then :copyright
      end
      add_token(match, type)
    end

    def tokenize_single
      match = scanner.getch
      add_token(match, SINGLES[match])
      true
    end

    def tokenize_dots
      match = scanner.scan(/\.+/)
      type = case match.length
      when 1
        :single_dot
      when 2
        :double_dot
      else
        :unknown
      end
      add_token(match, type)
      true
    end

    def tokenize_hyphens
      hyphens = (HYPHENS - ["-"]).join
      pattern = Regexp.new("[-#{hyphens}]+")
      match = scanner.scan(pattern)
      case match.length
      when 1
        if preceded_by_3_digit_number? && !followed_by_number?
          tokens << UncertaintyDigits.new(lexeme: match)
        else
          add_token(match, :hyphen)
        end
      when 2
        if preceded_by_2_digit_number? && !followed_by_number?
          tokens << UncertaintyDigits.new(lexeme: match)
        elsif preceded_by_number?
          add_uncertainty_digits_followed_by_hyphen(match)
        else
          add_multiple_hyphens(match)
        end
      when 3
        if preceded_by_1_digit_number? && !followed_by_number?
          tokens << UncertaintyDigits.new(lexeme: match)
        elsif preceded_by_number?
          add_uncertainty_digits_followed_by_hyphen(match)
        else
          add_multiple_hyphens(match)
        end
      end
      true
    end

    def add_multiple_hyphens(match)
      match.chars.each { |char| add_token(char, :hyphen) }
    end

    def add_uncertainty_digits_followed_by_hyphen(match)
      tokens << UncertaintyDigits.new(lexeme: match[0..-2])
      add_token(match[-1], :hyphen)
    end

    def followed_by_number? = scanner.rest.match?(/^\d/)

    def preceded_by_1_digit_number? = preceded_by_number? &&
      tokens.last.digits == 1

    def preceded_by_2_digit_number? = preceded_by_number? &&
      tokens.last.digits == 2

    def preceded_by_3_digit_number? = preceded_by_number? &&
      tokens.last.digits == 3

    def preceded_by_number? = tokens.last&.number?

    def tokenize_number
      match = scanner.scan(/\d+/)
      tokens << Number.new(lexeme: match)
      tokenize_ordinal_indicator
    end

    def tokenize_ordinal_indicator
      indicator = ORDINAL_INDICATORS.find { |ind| ordinal_val_match?(ind) }
      return true unless indicator

      pattern = Regexp.new(indicator, Regexp::IGNORECASE)
      match = scanner.scan(pattern)
      add_token(match, :ordinal_indicator)
      true
    end

    def safe_peek(len = 1)
      tmp = StringScanner.new(scanner.rest)
      acc = []
      len.times { acc << tmp.getch }
      acc.join
    end

    def ordinal_val_match?(str)
      chk = safe_peek(str.length).downcase
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
      match = scanner.scan(pattern)
      if alpha?(safe_peek(1))
        addtl = scanner.scan(/[a-z]+/i)
        add_token(match + addtl, :unknown)
      else
        case ALPHA[pattern]
        when :month
          tokens << Emendate::MonthAlpha.new(
            lexeme: match,
            type: :month
          )
        when :season
          tokens << Emendate::SeasonAlpha.new(
            lexeme: match,
            type: :season
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
        when :uncertainty_digits
          tokens << UncertaintyDigits.new(lexeme: match)
        else
          add_token(match, ALPHA[pattern])
        end
      end
    end

    def single_alpha?
      scanner.rest.match?(/^[a-z]\b/i) ||
        scanner.rest.match?(/^[a-z]\d/i)
    end

    def tokenize_single_alpha
      char = scanner.scan(/./)
      type = :"letter_#{char.downcase}"
      add_token(char, type)
    end

    def tokenize_unknown_alpha
      match = scanner.scan(/[a-z]+/i)
      add_token(match, :unknown)
    end

    # @param lexeme [String]
    # @param type [Symbol]
    def add_token(lexeme, type)
      tokens << Emendate::Segment.new(
        lexeme: lexeme, type: type
      )
    end

    def digit?(char)
      char >= "0" && char <= "9"
    end

    def alpha?(char)
      /[a-z&]/i.match?(char)
    end
  end
end
