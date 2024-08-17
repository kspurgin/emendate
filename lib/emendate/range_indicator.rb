# frozen_string_literal: true

module Emendate
  class RangeIndicator
    include Dry::Monads[:result]

    class << self
      def call(...)
        new(...).call
      end
    end

    def initialize(tokens)
      @result = tokens.class.new.copy(tokens)
      @unhandled_mode = Emendate.set_unhandled_mode
    end

    def call
      kill_unhandled_range_indicators if has_range_indicator? &&
        unhandled_mode == :collapse_unhandled
      collapse_ranges while has_range_indicator?
      validate

      if collapsible_and_or_date?
        collapse_to_range
      end
      Success(result)
    end

    private

    attr_reader :result, :working, :unhandled_mode

    def kill_unhandled_range_indicators
      result.select { |seg| seg.type == :range_indicator }
        .each do |ri|
          next unless result.previous_segment(ri)&.type == :unknown ||
            result.next_segment(ri)&.type == :unknown

          result.replace_x_with_derived_new_type(x: ri, type: :unknown)
        end
    end

    def collapsible_and_or_date?
      Emendate.options.and_or_date_handling == :single_range &&
        result.types.any?(:date_separator)
    end

    def collapse_to_range
      @working = result.class.new.copy(result)
      result.clear

      datetypes = working.select { |token| token.date_type? }
      startdate = datetypes[0]
      enddate = datetypes[-1]
      [startdate, enddate].each { |token| working.delete(token) }
      indicator = Segment.new(type: :range_indicator, sources: working.segments)
      sources = working.class.new.copy(working)
      sources.clear
      [startdate, indicator, enddate].each { |token| sources << token }
      result << Emendate::DateTypes::Range.new(sources: sources)
    end

    def before_range_indicator?
      nxt.type == :range_indicator
    end

    def collapse_ranges
      @working = result.class.new.copy(result)
      result.clear

      collapse_range until working.empty?
    end

    def collapse_range
      unless current.date_type?
        passthrough
        return
      end

      if nxt.nil?
        passthrough
        return
      end

      unless before_range_indicator?
        passthrough
        return
      end

      sources = working.shift(3)
      result << Emendate::DateTypes::Range.new(sources: sources)
    end

    def current
      working[0]
    end

    def has_range_indicator?
      result.types.include?(:range_indicator)
    end

    def nxt(n = 1)
      working[n]
    end

    def passthrough
      result << working.shift
    end

    def passthrough_all
      passthrough until working.empty?
    end

    def validate
      result.each do |part|
        next unless part.type == :range_date_type
        next if part.latest > part.earliest

        result.warnings << "Not a valid range: #{part.lexeme}"
      end
    end
  end
end
