# frozen_string_literal: true

module Emendate
  module DateTypes
    class MissingMillenniumTypeError < StandardError
      def initialize(types)
        m = "A millennium_type option with is required. Value must be one of the following: #{types.join(', ')}"
      super(m)
      end
    end

    class MillenniumTypeValueError < StandardError
      def initialize(types)
        m = "The millennium_type option must have one of the following values: #{types.join(', ')}"
        super(m)
      end
    end
    
    class Millennium < Emendate::DateTypes::DateType
      attr_reader :millennium, :millennium_type
      def initialize(**opts)
        super
        @millennium = opts[:millennium].is_a?(Integer) ? opts[:millennium] : opts[:millennium].to_i
        if opts[:millennium_type].nil?
          raise Emendate::DateTypes::MissingMillenniumTypeError.new(allowed_millennium_types)
        elsif !allowed_millennium_types.include?(opts[:millennium_type])
          raise Emendate::DateTypes::MillenniumTypeValueError.new(allowed_millennium_types)
        else
          @millennium_type = opts[:millennium_type]
        end

        adjust_millennium_value if millennium_type == :plural
      end

      def earliest
        yr = "#{millennium}000".to_i
        Date.new(yr, 1, 1)
      end

      def latest
        yr = "#{millennium}999".to_i
        Date.new(yr, 12, 31)
      end

      def lexeme
        case millennium_type
        when :plural
          "#{earliest.year}s"
        when :uncertainty_digits
          "#{millennium}XXX"
        end
      end

      private

      def adjust_millennium_value
        str = millennium.to_s[0..-4]
        @millennium = str.to_i
      end
      
      def allowed_millennium_types
        %i[plural uncertainty_digits]
      end
    end
  end
end
