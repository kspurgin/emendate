# frozen_string_literal: true

require_relative "error_util"

module Emendate
  class ProcessingManager
    include Dry::Monads[:result]
    include Dry::Monads::Do.for(:call)

    class << self
      def call(...)
        new(...).call
      end
    end

    attr_reader :orig_string
    attr_reader :history
    attr_reader :tokens
    attr_reader :errors
    attr_reader :warnings

    def initialize(string, options = {})
      @orig_string = string
      Emendate::Options.new(options) unless options.empty?
      @history = {initialized: orig_string}
      @tokens = Emendate::SegmentSets::SegmentSet.new(
        string: orig_string
      )
      @errors = []
      @warnings = []
    end

    def call
      Emendate::PROCESSING_STEPS.each do |step, state|
        yield handle_step(
          state: state, proc: proc { step.call(tokens) }
        )
      end
      _final_checked = yield final_check

      @history[:done] = nil
      Success(self)
    end

    def state
      history.keys.last
    end

    def historical_record
      history.each do |state, val|
        puts state
        outval = if val.is_a?(String)
          val
        elsif val.respond_to?(:segments) && val.empty?
          val.norm
        elsif val.respond_to?(:types)
          "types: #{val.types.inspect}\n  "\
            "qualifiers: #{val.qualifiers.map(&:type)}"
        end
        puts "  #{outval}" if outval
      end
      nil
    end
    alias_method :hr, :historical_record

    def to_s
      <<~OBJ
        #<#{self.class.name}:#{object_id}
          state=#{state},
          token_type_pattern: #{tokens.types.inspect}>
      OBJ
    end
    alias_method :inspect, :to_s

    def result
      Emendate::Result.new(self)
    end

    private

    def call_step(step)
      step.call
    rescue => e
      Failure(e)
    end

    def final_check
      if !errors.empty? || tokens.any? { |token| !token.processed? }
        message = "Unhandled segment still present"
        errors << message
        history[:final_check_failed] = message
        Failure(self)
      else
        history[:final_check_passed] = nil
        Success()
      end
    end

    def add_error?
      no_error_states = %i[
        known_unknown_tagged_failure
        untokenizable_tagged_failure
      ]
      true unless no_error_states.any? do |nes|
                    state.to_s.start_with?(nes.to_s)
                  end
    end

    def handle_step(state:, proc:)
      call_step(proc).either(
        lambda do |success|
          @tokens = success
          @history[state] = success
          add_warnings(success.warnings) if success.respond_to?(:warnings)
          Success()
        end,
        lambda do |failure|
          @history[:"#{state}_failure"] = nil
          if add_error?
            errors << failure
          elsif failure.is_a?(
            Emendate::SegmentSets::SegmentSet
          )
            @tokens = failure
          end
          add_warnings(failure.warnings) if failure.respond_to?(:warnings)
          Failure(self)
        end
      )
    end

    def add_warnings(new_warnings)
      return if new_warnings.empty?

      warnings << new_warnings
      warnings.flatten!
      warnings.uniq!
    end

    def errors?
      !errors.empty?
    end

    def no_errors?
      errors.empty?
    end

    def known_unknown?
      tokens.types == [:knownunknown_date_type]
    end
  end
end
