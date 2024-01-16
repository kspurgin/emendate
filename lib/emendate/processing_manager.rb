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

    attr_reader :orig_string, :history, :tokens, :errors, :warnings

    def initialize(string, options = {})
      @orig_string = string
      Emendate::Options.new(options) unless options.empty?
      @history = {initialized: orig_string}
      @tokens = Emendate::SegmentSets::TokenSet.new(
        string: orig_string
      )
      @errors = []
      @warnings = []
    end

    def call
      _lexed = yield handle_step(
        state: :lexed,
        proc: -> { Emendate::Lexer.call(tokens) }
      )
      _untokenizable_tagged = yield handle_step(
        state: :untokenizable_tagged,
        proc: -> { Emendate::UntokenizableTagger.call(tokens) }
      )
      _unprocessable_tagged = yield handle_step(
        state: :unprocessable_tagged,
        proc: -> { Emendate::UnprocessableTagger.call(tokens) }
      )
      _known_unknown_tagged = yield handle_step(
        state: :known_unknown_tagged,
        proc: -> { Emendate::KnownUnknownTagger.call(tokens) }
      )
      _tokens_collapsed = yield handle_step(
        state: :tokens_collapsed,
        proc: -> { Emendate::TokenCollapser.call(tokens) }
      )
      _months_converted = yield handle_step(
        state: :months_converted,
        proc: -> { Emendate::AlphaMonthConverter.call(tokens) }
      )
      _ordinals_translated = yield handle_step(
        state: :ordinals_translated,
        proc: -> { Emendate::OrdinalTranslator.call(tokens) }
      )
      _edtf_sets_handled = yield handle_step(
        state: :edtf_sets_handled,
        proc: -> { Emendate::EdtfSetHandler.call(tokens) }
      )
      _certainty_checked = yield handle_step(
        state: :certainty_checked,
        proc: -> { Emendate::CertaintyChecker.call(tokens) }
      )
      _format_standardized = yield handle_step(
        state: :format_standardized,
        proc: -> { Emendate::FormatStandardizer.call(tokens) }
      )
      _date_parts_tagged = yield handle_step(
        state: :date_parts_tagged,
        proc: -> { Emendate::DatePartTagger.call(tokens) }
      )
      _dates_segmented = yield handle_step(
        state: :dates_segmented,
        proc: -> { Emendate::DateSegmenter.call(tokens) }
      )
      _ranges_indicated = yield handle_step(
        state: :ranges_indicated,
        proc: -> { Emendate::RangeIndicator.call(tokens) }
      )
      _cleaned = yield handle_step(
        state: :tokens_cleaned,
        proc: -> { Emendate::TokenCleaner.call(tokens) }
      )
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
            "certainty: #{val.certainty.inspect}"
        end
        puts "  #{outval}" if outval
      end
      nil
    end

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
