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
      attr_reader :decade, :decade_type
      def initialize(**opts)
        super
        @decade = opts[:decade].is_a?(Integer) ? opts[:decade] : opts[:decade].to_i
        if opts[:decade_type].nil?
          raise Emendate::DateTypes::MissingDecadeTypeError.new(allowed_decade_types)
        elsif !allowed_decade_types.include?(opts[:decade_type])
          raise Emendate::DateTypes::DecadeTypeValueError.new(allowed_decade_types)
        else
          @decade_type = opts[:decade_type]
        end

        adjust_decade_value if decade_type == :plural
      end

      def earliest
        yr = "#{decade}0".to_i
        Date.new(yr, 1, 1)
      end

      def latest
        yr = "#{decade}9".to_i
        Date.new(yr, 12, 31)
      end

      def lexeme
        case decade_type
        when :plural
          "#{earliest.year}s"
        when :uncertainty_digits
          "#{decade}X"
        end
      end

      private

      def adjust_decade_value
        str = decade.to_s[0..-2]
        @decade = str.to_i
      end
      
      def allowed_decade_types
        %i[plural uncertainty_digits]
      end
    end
  end
end
