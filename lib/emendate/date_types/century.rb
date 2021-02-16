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
      attr_reader :literal, :century_type
      def initialize(**opts)
        super
        @literal = opts[:literal].is_a?(Integer) ? opts[:literal] : opts[:literal].to_i
        if opts[:century_type].nil?
          raise Emendate::DateTypes::MissingCenturyTypeError.new(allowed_century_types)
        elsif !allowed_century_types.include?(opts[:century_type])
          raise Emendate::DateTypes::CenturyTypeValueError.new(allowed_century_types)
        else
          @century_type = opts[:century_type]
        end
      end

      def earliest
        Date.new(earliest_year, 1, 1)
      end

      def latest
        Date.new(latest_year, 12, 31)
      end

      def lexeme
        case century_type
        when :name
          "#{literal} century"
        when :plural
          "#{literal}00s"
        when :uncertainty_digits
          "#{literal}uu"
        end
      end

      def range?
        true
      end
      
      private

      def adjusted_century
        century_type == :name ? literal - 1 : literal
      end

      def allowed_century_types
        %i[name plural uncertainty_digits]
      end

      def named_century_earliest_year
        ( adjusted_century.to_s + '00' ).to_i + 1
      end

      def other_century_earliest_year
        ( adjusted_century.to_s + '00' ).to_i
      end

      def earliest_year
        year = century_type == :name ? named_century_earliest_year : other_century_earliest_year
        case partial_indicator
        when nil
          year
        when 'early'
          year
        when 'mid'
          year + 33
        when 'late'
          year + 66
        end
      end

      def latest_year
        year = century_type == :name ? named_century_earliest_year : other_century_earliest_year
        case partial_indicator
        when nil
          year + 99
        when 'early'
          year + 33
        when 'mid'
          year + 66
        when 'late'
          year + 99
        end
      end
    end
  end
end
