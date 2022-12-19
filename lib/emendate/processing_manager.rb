# frozen_string_literal: true

require_relative 'error_util'

module Emendate
  class ProcessingManager
    include Dry::Monads[:result]
    include Dry::Monads::Do.for(:call)

    class << self
      def call(...)
        self.new(...).call
      end
    end

    attr_reader :orig_string, :tokens, :state, :errors, :warnings

    def initialize(string, options = {})
      @orig_string = string
      Emendate::Options.new(options) unless options.empty?
      @tokens = Emendate::SegmentSets::TokenSet.new
      @state = :initialized
      @errors = []
      @warnings = []
    end

    def call
      _lexed = yield handle_step(
        state: :lexed,
        proc: ->{ Emendate::Lexer.call(orig_string) }
      )
      _untokenizable_tagged = yield handle_step(
        state: :untokenizable_tagged,
        proc: ->{ Emendate::UntokenizableTagger.call(tokens) }
      )
      _unprocessable_tagged = yield handle_step(
        state: :unprocessable_tagged,
        proc: ->{ Emendate::UnprocessableTagger.call(tokens) }
      )

      Success(self)
    end

    # def process
    #   tag_known_unknown if may_tag_known_unknown?
    #   exit_if_known_unknown if may_exit_if_known_unknown?
    #   collapse_tokens if may_collapse_tokens?
    #   convert_months if may_convert_months?
    #   translate_ordinals if may_translate_ordinals?
    #   certainty_check if may_certainty_check?
    #   standardize_formats if may_standardize_formats?
    #   tag_date_parts if may_tag_date_parts?
    #   segment_dates if may_segment_dates?
    #   indicate_ranges if may_indicate_ranges?
    #   finalize if may_finalize?
    # end

    def to_s
      <<~OBJ
      #<#{self.class.name}:#{self.object_id}
        @state=#{state},
        token_type_pattern: #{tokens.types.inspect}>
      OBJ
    end
    alias_method :inspect, :to_s

    def result
      Emendate::Result.new(self)
    end

    private

    def handle_step(state:, proc:)
      proc.call.either(
        ->(success) do
          @tokens = success
          @state = state
          add_warnings(success.warnings)
          Success()
        end,
        ->(failure) do
          errors << failure
          @state = "#{state}_failure".to_sym
          add_warnings(failure.warnings)
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
