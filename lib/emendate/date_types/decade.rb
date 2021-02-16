# frozen_string_literal: true

module Emendate
  module DateTypes
    class MissingDecadeTypeError < StandardError
      def initialize(types)
        m = "A decade_type option with is required. Value must be one of the following: #{types.join(', ')}"
      super(m)
      end
    end

    class DecadeTypeValueError < StandardError
      def initialize(types)
        m = "The decade_type option must have one of the following values: #{types.join(', ')}"
        super(m)
      end
    end
    
    class Decade < Emendate::DateTypes::DateType
      attr_reader :literal, :decade_type
      def initialize(**opts)
        super
        @literal = opts[:literal].is_a?(Integer) ? opts[:literal] : opts[:literal].to_i
        if opts[:decade_type].nil?
          raise Emendate::DateTypes::MissingDecadeTypeError.new(allowed_decade_types)
        elsif !allowed_decade_types.include?(opts[:decade_type])
          raise Emendate::DateTypes::DecadeTypeValueError.new(allowed_decade_types)
        else
          @decade_type = opts[:decade_type]
        end

        adjust_literal_value if decade_type == :plural
      end

      def earliest
        Date.new(earliest_year, 1, 1)
      end

      def latest
        Date.new(latest_year, 12, 31)
      end

      def lexeme
        case decade_type
        when :plural
          val = "#{decade_earliest_year}s"
        when :uncertainty_digits
          val = "#{literal}X"
        end

        val = "#{partial_indicator} #{val}" unless partial_indicator.nil?
        val
      end

      def range?
        true
      end

      private

      def decade_earliest_year
        ( literal.to_s + '0' ).to_i
      end

      def earliest_year
        year = decade_earliest_year
        case partial_indicator
        when nil
          year
        when 'early'
          year
        when 'mid'
          year + 4
        when 'late'
          year + 7
        end
      end

      def latest_year
        year = decade_earliest_year
        case partial_indicator
        when nil
          year + 9
        when 'early'
          year + 3
        when 'mid'
          year + 6
        when 'late'
          year + 9
        end
      end

      def adjust_literal_value
        str = literal.to_s[0..-2]
        @literal = str.to_i
      end
      
      def allowed_decade_types
        %i[plural uncertainty_digits]
      end
    end
  end
end
