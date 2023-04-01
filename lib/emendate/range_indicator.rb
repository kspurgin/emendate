# frozen_string_literal: true

module Emendate
  class RangeIndicator
    include Dry::Monads[:result]

    class << self
      def call(...)
        self.new(...).call
      end
    end

    def initialize(tokens)
      @working = tokens.class.new.copy(tokens)
      @result = tokens.class.new.copy(tokens)
      result.clear
    end

    def call
      has_range_indicator? ? handle_range : passthrough_all
      Success(result)
    end

    private

    attr_reader :result, :working

    def before_range_indicator?
      nxt.type == :range_indicator
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

      sources = working.class.new.copy(working)
      sources.clear
      [current, nxt, nxt(2)].each do |segmt|
        sources << segmt
        working.delete(segmt)
      end

      result << Emendate::DateTypes::Range.new(sources: sources)

    end

    def current
      working[0]
    end

    def handle_range
      collapse_range until working.empty?

      validate
    end

    def has_range_indicator?
      working.types.include?(:range_indicator)
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
