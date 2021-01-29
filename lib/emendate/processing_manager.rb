# frozen_string_literal: true

module Emendate
  class ProcessingManager
    include AASM
    attr_reader :orig_string, :norm_string, :tokens,
      :orig_tokens, :converted_months, :translated_ordinals, :standardized_formats,
      :tagged_date_parts, :errors
    def initialize(string)
      @orig_string = string
      @norm_string = Emendate.normalize_orig(orig_string)
      @tokens = Emendate::TokenSet.new
      @errors = []
    end

    aasm do
      state :startup, initial: true
      state :tokenized, :months_converted, :ordinals_translated, :formats_standardized,
        :date_parts_tagged, :done, :failed

      after_all_transitions :log_status_change
      
      event :lex do
        transitions from: :startup, to: :tokenized, after: :perform_lex
      end
      event :convert_months do
        transitions from: :tokenized, to: :months_converted, after: :perform_convert_months, guard: :no_errors?
      end
      event :translate_ordinals do
        transitions from: :months_converted, to: :ordinals_translated, after: :perform_translate_ordinals, guard: :no_errors?
      end
      event :standardize_formats do
        transitions from: :ordinals_translated, to: :formats_standardized, after: :perform_standardize_formats, guard: :no_errors?
      end
      event :tag_date_parts do
        transitions from: :formats_standardized, to: :date_parts_tagged, after: :perform_tag_date_parts, guard: :no_errors?
      end
      event :finalize do
        transitions from: :tokenized, to: :done, guard: :no_errors?
        transitions from: :tokenized, to: :failed, guard: :errors?
        transitions from: :months_converted, to: :done, guard: :no_errors?
        transitions from: :months_converted, to: :failed, guard: :errors?
        transitions from: :ordinals_translated, to: :done, guard: :no_errors?
        transitions from: :ordinals_translated, to: :failed, guard: :errors?
        transitions from: :formats_standardized, to: :done, guard: :no_errors?
        transitions from: :formats_standardized, to: :failed, guard: :errors?
        transitions from: :date_parts_tagged, to: :done, guard: :no_errors?
        transitions from: :date_parts_tagged, to: :failed, guard: :errors?
      end
    end

    def process
      lex
      convert_months if may_convert_months?
      translate_ordinals if may_translate_ordinals?
      standardize_formats if may_standardize_formats?
      tag_date_parts if may_tag_date_parts?
      finalize
    end

    def prep_for(event)
      ready = false
      until ready
        events = aasm.events.map(&:name)
        if events.include?(event)
          ready = true
        else
          send("may_#{events[0]}?".to_sym) ? send(events[0]) : ready = true
        end
      end
      finalize
    end

    def state
      aasm.current_state
    end

    private

    def perform_lex
      l = Emendate::Lexer.new(norm_string)
      begin
        l.tokenize
      rescue Emendate::UntokenizableError => e
        errors << e
      else
        @norm_string = l.norm
        @tokens = l.tokens
        @orig_tokens = tokens.dup
      end
    end

    def perform_convert_months
      c = Emendate::AlphaMonthConverter.new(tokens: tokens)
      c.convert
      @tokens = c.result
      @converted_months = tokens.dup
    end

    def perform_translate_ordinals
      t = Emendate::OrdinalTranslator.new(tokens: converted_months)
      begin
        t.translate
      rescue StandardError => e
        errors << e
      else
        @tokens = t.result
        @translated_ordinals = tokens.dup
      end
    end

    def perform_standardize_formats
      f = Emendate::FormatStandardizer.new(tokens: translated_ordinals)
      begin
        f.standardize
      rescue StandardError => e
        errors << e
      else
        @tokens = f.result
        @standardized_formats = tokens.dup
      end
    end

    def perform_tag_date_parts
      t = Emendate::DatePartTagger.new(tokens: standardized_formats)
      t.tag
      @tokens = t.result
      @tagged_date_parts = tokens.dup
    end
    
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
