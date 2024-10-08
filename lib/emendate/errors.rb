# frozen_string_literal: true

module Emendate
  Error = Module.new

  class DateTypeCreationError < StandardError
    include Emendate::Error
  end

  class DecadeTypeError < StandardError
    include Emendate::Error

    def initialize(lexeme)
      m = "Cannot determine decade_type for #{lexeme}"
      super(m)
    end
  end

  class DerivedSegmentError < StandardError
    include Emendate::Error

    attr_reader :sources

    def initialize(sources, message)
      @sources = sources
      m = "With sources: #{sources.type_string}: #{message}"
      super(m)
    end
  end

  class ForbiddenSegmentAdditionError < StandardError
    include Emendate::Error

    def initialize(token, meth, klass)
      type = token.type
      verb = meth.to_s.split("_").first
      m = "Cannot #{verb} :#{type} segment to #{klass} sources"
      super(m)
    end
  end

  class ImpossibleCollapseError < StandardError
    include Emendate::Error
    def initialize(dir)
      adj = (dir == :forward) ? :initial : :final
      super("Cannot collapse #{adj} segment #{dir}")
    end
  end

  class InvalidDateError < StandardError
    include Emendate::Error
  end

  class EmptyTestSetError < StandardError
    include Emendate::Error
  end

  class MillenniumTypeError < StandardError
    include Emendate::Error

    def initialize(lexeme)
      m = "Cannot determine millennium_type for #{lexeme}"
      super(m)
    end
  end

  class MonthDayError < StandardError
    include Emendate::Error
    def initialize(n1, n2, y)
      m = "Cannot determine valid month/date assignment for "\
          "#{n1.literal} and #{n2.literal} with year: #{y.lexeme}"
      super(m)
    end
  end

  class MonthDayYearError < StandardError
    include Emendate::Error

    def initialize(tokens)
      m = "Cannot determine any valid month/day/year combination for "\
          "#{tokens.map(&:lexeme).join("-")}"
      super(m)
    end
  end

  class MonthLiteralError < StandardError
    include Emendate::Error

    def initialize(lexeme)
      m = "Cannot assign literal for month value `#{lexeme}`. Dates will not "\
          "be translateable until DateUtils and/or MonthAlpha is updated "\
          "to assign the appropriate literal value"
      super(m)
    end
  end

  class NonDateTypeError < TypeError
    include Emendate::Error
  end

  class PreferredMdyOrderInvalidError < StandardError
    include Emendate::Error

    def initialize(tokens)
      m = "Using ambiguous MDY order "\
        "#{Emendate.options.ambiguous_month_day_year} results in invalid "\
        "date for: #{tokens.map(&:lexeme).join("-")}"
      super(m)
    end
  end

  class QualifierTypeError < TypeError
    include Emendate::Error

    def initialize
      super("Qualifer must be an Emendate::Qualifier")
    end
  end

  class RangeStartOpenError < StandardError
    include Emendate::Error

    def initialize
      m = "When :point is `:start`, :category cannot be `:open`. Set "\
          ":category to `:unknown`"
      super(m)
    end
  end

  class SeasonLiteralError < StandardError
    include Emendate::Error

    def initialize(lexeme)
      m = "Cannot assign literal for season value `#{lexeme}`. Dates will not "\
          "be translateable until SeasonAlpha is updated "\
          "to assign the appropriate literal value"
      super(m)
    end
  end

  class TokenLexemeError < StandardError
    include Emendate::Error
  end

  class TokenTypeError < StandardError
    include Emendate::Error
  end

  class UnexpectedPluralizedYearPatternError < StandardError
    include Emendate::Error
  end

  class UnsegmentableDatePatternError < StandardError
    include Emendate::Error

    def initialize(pieces)
      msg = pieces.types.join(", ")
      super(msg)
    end
  end

  class UntaggableDatePatternError < StandardError
    include Emendate::Error

    def initialize(date_parts, reason)
      msg = "value: #{date_parts.map(&:lexeme).join}; reason: #{reason}"
      super(msg)
    end
  end
end
