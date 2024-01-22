# frozen_string_literal: true

require_relative "error_util"

module Emendate
  # Runs {PROCESSING_STEPS processing steps} on the given string, gathering any
  # errors or warnings.
  #
  # If no failure occurs, all steps are run.
  #
  # If a failure occurs in a processing step, subsequent steps are not
  # attempted. The failure state is informationally handled by the
  # {ProcessingManager} so that it doesn't blow up batch processing and can be
  # reported out in consistent ways.
  #
  # For understanding how dates are processed or debugging in the console, the
  # {ProcessingManager} keeps track of the state of the processed string at the
  # end of every step. The :historical_record (aliased to :hr) method gives an
  # overview by printing each step and its resulting {Segment} types to STDOUT.
  # The :history method gives you access to the {SegmentSet} returned by each
  # step.
  #
  # In console, calling ~Emendate.process~ with your string and optional options
  # is a shortcut for doing ~ProcessingManager.new(string).call~ or
  # ~ProcessingManager.call(string)~ or
  class ProcessingManager
    include Dry::Monads[:result]
    include Dry::Monads::Do.for(:call)

    class << self
      # (see #initialize)
      # @return [ProcessingManager]
      def call(...)
        new(...).call
      end
    end

    # @return [String]
    attr_reader :orig_string
    # @return [Hash] keys are step state values from {PROCESSING_STEPS
    #   processing steps}; values are the {SegmentSets::SegmentSet}s
    #   returned for each successfully completed step; informational
    #   message string if state is a failure, or nil for the :done
    #   state; See also {#historical_record}
    attr_reader :history
    # @return [SegmentSets::SegmentSet]
    attr_reader :tokens
    # Reasons why processing could not be completed
    # @return [Array<#backtrace, Symbol>] Ruby error objects or brief error
    #   messages as Symbols
    attr_reader :errors
    # May provide additional information on why processing could not be
    # completed (such as which parts of the string could not be tokenized), or
    # ambiguities/issues introduced by application of options which you may
    # wish to review.
    # @return [Array]
    attr_reader :warnings

    # @param string [String] to process
    # @macro optionsparam
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

    # Runs the {PROCESSING_STEPS processing steps}
    # @return [ProcessingManager]
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

    # @return [Symbol] indication of whether processing is complete, and, if
    #   not, where it stopped
    def state
      history.keys.last
    end

    # Call this method in console to see a quick overview of the output of each
    # {PROCESSING_STEPS processing step}: the segment types returned, and any
    # qualifiers identified.
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

    # @return [String] representation of {ProcessingManager}
    def to_s
      <<~OBJ
        #<#{self.class.name}:#{object_id}
          state=#{state_for_inspect},
          token_type_pattern: #{tokens.types.inspect}>
      OBJ
    end
    alias_method :inspect, :to_s

    # @return [Result]
    def result
      Emendate::Result.new(self)
    end

    private

    def state_for_inspect
      return state unless state.to_s.end_with?("failure")

      "#{state} (Call :errors on this instance for details)"
    end

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
          @history[:"#{state}_failure"] = "Call :errors method on "\
            "ProcessingManager object for details"
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
