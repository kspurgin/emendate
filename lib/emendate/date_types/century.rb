# frozen_string_literal: true

module Emendate
  module DateTypes
    class MissingCenturyTypeError < StandardError
      def initialize(types)
        m = "A century_type option with is required. Value must be one of the following: #{types.join(', ')}"
      super(m)
      end
    end

    class CenturyTypeValueError < StandardError
      def initialize(types)
        m = "The century_type option must have one of the following values: #{types.join(', ')}"
        super(m)
      end
    end
    
    class Century < Emendate::DateTypes::DateType
      attr_reader :century, :century_type
      def initialize(**opts)
        super
        @century = opts[:century].is_a?(Integer) ? opts[:century] : opts[:century].to_i
        if opts[:century_type].nil?
          raise Emendate::DateTypes::MissingCenturyTypeError.new(allowed_century_types)
        elsif !allowed_century_types.include?(opts[:century_type])
          raise Emendate::DateTypes::CenturyTypeValueError.new(allowed_century_types)
        else
          @century_type = opts[:century_type]
        end
      end

      def earliest
        yr = ( adjusted_century.to_s + '00' ).to_i
        yr = yr + 1 if century_type == :name
        Date.new(yr, 1, 1)
      end

      def latest
        century_type == :name ? name_latest : other_latest
      end

      def lexeme
        case century_type
        when :name
          "#{century} century"
        when :plural
          "#{century}00s"
        when :uncertainty_digits
          "#{century}uu"
        end
      end

      private

      def adjusted_century
        century_type == :name ? century - 1 : century
      end

      def allowed_century_types
        %i[name plural uncertainty_digits]
      end

      def name_latest
        yr = (century.to_s + '00').to_i
        Date.new(yr, 12, 31)
      end

      def other_latest
        yr = (century.to_s + '99').to_i
        Date.new(yr, 12, 31)
      end
    end
  end
end
