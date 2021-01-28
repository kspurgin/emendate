# frozen_string_literal: true

module Emendate
  class ProcessingManager
    include AASM
    attr_reader :orig_string, :norm_string, :tokens,
      :orig_tokens, :errors
    def initialize(string)
      @orig_string = string
      @norm_string = Emendate.normalize_orig(orig_string)
      @errors = []
    end

    aasm do
      state :startup, initial: true
      state :tokenized, :months_converted, :ordinals_translated, :formats_standardized, :done, :failed

      after_all_transitions :log_status_change
      
      event :lex do
        transitions from: :startup, to: :tokenized, after: :perform_lex
        transitions from: :tokenized, to: :failed, guard: :errors?
      end
      event :convert_months do
        transitions from: :tokenized, to: :months_converted, guard: :no_errors?
      end
      event :translate_ordinals do
        transitions from: :months_converted, to: :ordinals_translated
      end
      event :standardize_formats do
        transitions from: :ordinals_translated, to: :formats_standardized
      end
      event :finalize do
        transitions from: :tokenized, to: :done, guard: :no_errors?
        transitions from: :tokenized, to: :failed, guard: :errors?
        transitions from: :months_converted, to: :done, guard: :no_errors?
        transitions from: :months_converted, to: :failed, guard: :errors?
      end
    end

    def process
      
    end

    def stupid
    end
    
    def perform_lex
      l = Emendate::Lexer.new(norm_string)
      begin
        l.tokenize
      rescue Emendate::UntokenizableError => e
        errors << e
        true
      else
        @norm_string = l.norm
        @tokens = l.tokens
        true
      end
    end

    def convert_months
    end

    def state
      aasm.current_state
    end

    private

    def log_status_change
      puts "changing from #{aasm.from_state} to #{aasm.to_state} (event: #{aasm.current_event})"
    end

    def errors?
      errors.empty? ? false : true
    end
    
    def no_errors?
      errors.empty? ? true : false
    end
  end
end
