# frozen_string_literal: true

module Emendate
  def normalize_orig(orig)
    orig.downcase.sub('[?]', '?')
      .sub('(?)', '?')
      .sub(/^c([^a-z])/, 'circa\1') # initial c followed by non-letter
      .gsub(/b\.?c\.?(e\.?|)/, 'bce') # cleanup bc, bce
      .gsub(/(a\.?d\.?|c\.?e\.?)/, 'ce') # cleanup ad, ce
      .gsub(/b\.?p\.?/, 'bp') # cleanup bp
      .sub(/^n\.? ?d\.?$/, 'nodate') # cleanup nd
      .sub(/^ *not dated *$/, 'notdated') # cleanup not dated
      .sub(/^ unkn?\.? *$/, 'unk') # cleanup unk.
      .sub(/(st|nd|rd|th) c\.?$/, '\1 century') # ending c after ordinal
  end

  class UntokenizableError < StandardError
    attr_reader :segments

    def initialize(unknown_tokens:)
      @segments = unknown_tokens.map{ |t| "#{Emendate::LQ}#{t.lexeme}#{Emendate::RQ}" }
      super(segments.join(', '))
    end
  end

  class Lexer
    # ambiguous things
    # c - at beginning = circa, at end = century
    # nd - if directly after number, ordinal indicator; otherwise unknown date. normalize_orig attempts
    #      to clear this up for most cases.
    AFTER = %w[after post].freeze
    AND = ['&', 'and'].freeze
    BEFORE = %w[before pre].freeze
    CENTURY = %w[century cent].freeze
    CIRCA = %w[ca circa].freeze
    COLON = ':'
    COMMA = ','
    CURLY_BRACKET_OPEN = '{'
    CURLY_BRACKET_CLOSE = '}'
    DAYS = (Date::DAYNAMES + Date::ABBR_DAYNAMES).compact.map(&:downcase).freeze
    DOT = '.'
    ERA = %w[bce ce bp].freeze
    HYPHEN = ["\u002D", "\u2010", "\u2011", "\u2012", "\u2013", "\u2014", "\u2015", "\u2043"].freeze
    MONTHS = Date::MONTHNAMES.compact.map(&:downcase).freeze
    MONTH_ABBREVS = Date::ABBR_MONTHNAMES.compact.map(&:downcase).freeze
    QUESTION = '?'
    OR_INDICATOR = %w[or].freeze
    ORDINAL_INDICATOR = %w[st nd rd th d].freeze
    PERCENT = '%'
    PARTIAL = %w[early late middle mid].freeze
    PLUS = '+'
    RANGE_INDICATOR = %w[to]
    SEASONS = %w[winter spring summer fall autumn]
    SLASH = '/'
    SPACE = ' '
    SQUARE_BRACKET_OPEN = '['
    SQUARE_BRACKET_CLOSE = ']'
    TILDE = '~'
    UNKNOWN_DATE = %w[nodate notdated undated unk unknown].freeze

    attr_reader :norm, :tokens
    attr_accessor :next_p, :lexeme_start_p

    def initialize(norm_string)
      @norm = norm_string
      @tokens = Emendate::TokenSet.new
      @next_p = 0
      @lexeme_start_p = 0
    end

    def tokenize
      while norm_uncompleted?
        tokenization
      end
      finalize
    end

    private

    def finalize
      if tokens.any_unknown?
        raise Emendate::UntokenizableError.new(unknown_tokens: tokens.unknown)
      else
        self
      end
    end

    def tokenization
      self.lexeme_start_p = next_p

      c = consume

      token =
        if c == COLON
          token_of_type(c, :colon)
        elsif c == COMMA
          token_of_type(c, :comma)
        elsif c == CURLY_BRACKET_OPEN
          token_of_type(c, :curly_bracket_open)
        elsif c == CURLY_BRACKET_CLOSE
          token_of_type(c, :curly_bracket_close)
        elsif c == DOT
          dots
        elsif HYPHEN.include?(c)
          token_of_type(c, :hyphen)
        elsif c == PERCENT
          token_of_type(c, :percent)
        elsif c == PLUS
          token_of_type(c, :plus)
        elsif c == QUESTION
          token_of_type(c, :question)
        elsif c == SLASH
          token_of_type(c, :slash)
        elsif c == SPACE
          token_of_type(c, :space)
        elsif c == SQUARE_BRACKET_OPEN
          token_of_type(c, :square_bracket_open)
        elsif c == SQUARE_BRACKET_CLOSE
          token_of_type(c, :square_bracket_close)
        elsif c == TILDE
          token_of_type(c, :tilde)
        elsif digit?(c)
          number
        elsif alpha?(c)
          letter
        end

      return if token.nil? && c == DOT

      token = Token.new(lexeme: c, type: :unknown, location: current_location) if token.nil?


      tokens << token
    end

    def token_of_type(lexeme, type)
      Token.new(lexeme: lexeme, type: type, location: current_location)
    end

    def consume
      c = lookahead
      self.next_p += 1
      c
    end

    def consume_digits
      while digit?(lookahead)
        consume
      end
    end

    def consume_letters
      while alpha?(lookahead)
        consume
      end
    end

    def consume_dots
      while dot?(lookahead)
        consume
      end
    end

    def dots
      consume_dots
      lexeme = norm[lexeme_start_p..(next_p - 1)]

      case lexeme.length
      when 1
        type = :single_dot
      when 2
        type = :double_dot
      else
        type = :unknown
      end

      Token.new(type: type, lexeme: lexeme, location: current_location)
    end

    def letter
      consume_letters
      lexeme = norm[lexeme_start_p..(next_p - 1)]
      type = letter_type(lexeme)
      Token.new(type: type, lexeme: lexeme, location: current_location)
    end

    def letter_type(lexeme)
      if AFTER.include?(lexeme)
        :after
      elsif AND.include?(lexeme)
        :and
      elsif BEFORE.include?(lexeme)
        :before
      elsif CENTURY.include?(lexeme)
        :century
      elsif CIRCA.include?(lexeme)
        :approximate
      elsif DAYS.include?(lexeme)
        :day_of_week_alpha
      elsif ERA.include?(lexeme)
        :era
      elsif PARTIAL.include?(lexeme)
        :partial
      elsif MONTHS.include?(lexeme)
        :month_alpha
      elsif MONTH_ABBREVS.include?(lexeme)
        :month_abbr_alpha
      elsif OR_INDICATOR.include?(lexeme)
        :or
      elsif ORDINAL_INDICATOR.include?(lexeme)
        :ordinal_indicator
      elsif RANGE_INDICATOR.include?(lexeme)
        :range_indicator
      elsif SEASONS.include?(lexeme)
        :season
      elsif UNKNOWN_DATE.include?(lexeme)
        :unknown_date
      elsif lexeme.match?(/^x+$/)
        :uncertainty_digits
      elsif lexeme.match?(/^u+$/)
        :uncertainty_digits
      elsif lexeme == 'c'
        :letter_c
      elsif lexeme == 'e'
        :letter_e
      elsif lexeme == 's'
        :letter_s
      elsif lexeme == 't'
        :letter_t
      elsif lexeme == 'y'
        :letter_y
      elsif lexeme == 'z'
        :letter_z
      else
        :unknown
      end
    end

    def number
      consume_digits
      lexeme = norm[lexeme_start_p..(next_p - 1)]
      NumberToken.new(type: :number, lexeme: lexeme, location: current_location)
    end

    def lookahead(offset = 1)
      lookahead_p = (next_p - 1) + offset
      return "\0" if lookahead_p >= norm.length

      norm[lookahead_p]
    end


    def norm_completed?
      next_p >= norm.length # our pointer starts at 0, so the last char is length - 1.
    end

    def norm_uncompleted?
      !norm_completed?
    end

    def current_location
      Location.new(lexeme_start_p, next_p - lexeme_start_p)
    end

    def after_source_end_location
      Location.new(next_p, 1)
    end

    def alpha_numeric?(char)
      alpha?(char) || digit?(char)
    end

    def alpha?(char)
      char >= 'a' && char <= 'z' ||
        char == '&'
    end

    def digit?(char)
      char >= '0' && char <= '9'
    end

    def dot?(char)
      char == DOT
    end

  end
end
