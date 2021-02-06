# frozen_string_literal: true

module Emendate
  module DateTypes
    
    class DateType
      attr_reader :type, :partial_indicator, :certainty
      attr_accessor :parts
      def initialize(**opts)
        @parts = opts[:children].nil? ? [] : Emendate::MixedSet.new(opts[:children])
        @partial_indicator = opts[:partial_indicator]
        @certainty = opts[:certainty].nil? ? [] : opts[:certainty]
      end
      
      def earliest
        raise NotImplementedError
      end

      def latest
        raise NotImplementedError
      end

      def lexeme
        raise NotImplementedError
      end

      def type
        "#{self.class.name.split('::').last.downcase}_date_type".to_sym
      end
    end
  end
end
