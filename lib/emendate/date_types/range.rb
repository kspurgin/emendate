# frozen_string_literal: true

module Emendate
  module DateTypes

    class Range < Emendate::DateTypes::DateType
      attr_reader :startdate, :enddate
      def initialize(**opts)
        super
        @startdate = opts[:startdate]
        @enddate = opts[:enddate]
        ri = opts[:range_indicator]
        [startdate, ri, enddate].each{ |s| source_tokens << s }
      end

      def earliest
        return nil if startdate.nil?
        startdate.earliest
      end

      def latest
        return nil if enddate.nil?
        enddate.latest
      end

      def lexeme
        if earliest && latest
          "#{earliest.iso8601} - #{latest.iso8601}"
        elsif earliest
          "#{earliest.iso8601} -"
        elsif latest
          "- #{latest.iso8601}"
        end
      end

      def range?
        true
      end
    end
  end
end
