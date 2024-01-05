# frozen_string_literal: true

module Emendate
  Error = Module.new
  UnconfiguredModuleError = Class.new(NameError){ include Emendate::Error }

  class CenturyTypeValueError < TypeError
    include Emendate::Error

    def initialize(types)
      m = 'The century_type option must have one of the following values: ' \
          "#{types.join(', ')}"
      super(m)
    end
  end

  class EmptyTestSetError < StandardError
    include Emendate::Error
  end

  class MissingCenturyTypeError < TypeError
    include Emendate::Error

    def initialize(types)
      m = 'A century_type option with is required. Value must be one of the ' \
          "following: #{types.join(', ')}"
      super(m)
    end
  end

  class MonthDayError < StandardError
    include Emendate::Error
    def initialize(n1, n2, y)
      m = 'Cannot determine valid month/date assignment for ' \
          "#{n1.lexeme}-#{n2.lexeme}-#{y.lexeme}"
      super(m)
    end
  end

  class MonthDayYearError < StandardError
    include Emendate::Error

    def initialize(tokens)
      m = 'Cannot determine any valid month/day/year combination for ' \
          "#{tokens.map(&:lexeme).join('-')}"
      super(m)
    end
  end

  class MonthLiteralError < StandardError
    include Emendate::Error

    def initialize(lexeme)
      m = "Cannot assign literal for month value `#{lexeme}`. Dates will not " \
          'be translateable until DateUtils and/or MonthAlphaToken is updated ' \
          'to assign the appropriate literal value'
      super(m)
    end
  end

  class NonDateTypeError < TypeError
    include Emendate::Error
  end

  class PreferredMdyOrderInvalidError < StandardError
    include Emendate::Error

    def initialize(tokens)
      m = 'Using ambiguous MDY order ' \
          "#{Emendate.options.ambiguous_month_day_year} results in invalid date " \
          "for: #{tokens.map(&:lexeme).join('-')}"
      super(m)
    end
  end

  class SeasonLiteralError < StandardError
    include Emendate::Error

    def initialize(lexeme)
      m = "Cannot assign literal for season value `#{lexeme}`. Dates will not " \
          'be translateable until SeasonAlphaToken is updated ' \
          'to assign the appropriate literal value'
      super(m)
    end
  end

  class TokenLexemeError < StandardError
    include Emendate::Error
  end

  class TokenTypeError < StandardError
    include Emendate::Error
  end

  class UnsegmentableDatePatternError < StandardError
    include Emendate::Error
    attr_reader :pieces

    def initialize(pieces)
      @pieces = pieces
      msg = pieces.types.join(', ')
      super(msg)
    end
  end

  class UntaggableDatePartError < StandardError
    include Emendate::Error
    attr_reader :date_part, :reason

    def initialize(date_part, reason)
      @date_part = date_part
      @reason = reason
      msg = "type: #{date_part.type}; value: #{date_part.lexeme}; reason: #{reason}"
      super(msg)
    end
  end

  class UntaggableDatePatternError < StandardError
    include Emendate::Error
    attr_reader :date_parts, :reason

    def initialize(date_parts, reason)
      @date_parts = date_parts
      @reason = reason
      msg = "value: #{date_parts.map(&:lexeme).join}; reason: #{reason}"
      super(msg)
    end
  end
end
