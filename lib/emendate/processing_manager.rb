# frozen_string_literal: true

require_relative 'error_util'

module Emendate
  class ProcessingManager
    include AASM
    attr_reader :orig_string, :options, :norm_string, :tokens, :orig_tokens,
      :tagged_untokenizable,
      :tagged_unprocessable,
      :tagged_known_unknown,
      :collapsed_tokens,
      :converted_months,
      :translated_ordinals,
      :certainty_checked,
      :standardized_formats,
      :tagged_date_parts,
      :segmented_dates,
      :ranges_indicated,
      :result,
      :errors, :warnings

    def initialize(string, options = {})
      @orig_string = string
      @options = Emendate::Options.new(options)
      @norm_string = Emendate.normalize_orig(orig_string)
      @tokens = Emendate::SegmentSets::TokenSet.new
      @errors = []
      @warnings = []
    end

    aasm do
      state :startup, initial: true
      state :tokenized,
        :untokenizable_tagged,
        :unprocessable_tagged,
        :known_unknown_tagged,
        :tokens_collapsed,
        :months_converted,
        :ordinals_translated,
        :values_certainty_checked,
        :formats_standardized,
        :date_parts_tagged,
        :dates_segmented,
        :indicated_ranges,
        :final_segments_checked,
        :done, :failed

      after_all_transitions :log_status_change, :gather_warnings

      event :lex do
        transitions from: :startup, to: :tokenized, after: :perform_lex
      end
      event :tag_untokenizable do
        transitions from: :tokenized, to: :untokenizable_tagged, after: :perform_tag_untokenizable,
          guard: :no_errors?
      end
      event :exit_if_untokenizable do
        transitions from: :untokenizable_tagged, to: :done, guard: :untokenizable?
      end
      event :tag_unprocessable do
        transitions from: :untokenizable_tagged, to: :unprocessable_tagged, after: :perform_tag_unprocessable,
          guard: :no_errors?
      end
      event :exit_if_unprocessable do
        transitions from: :unprocessable_tagged, to: :done, guard: :unprocessable?
      end
      event :tag_known_unknown do
        transitions from: :unprocessable_tagged, to: :known_unknown_tagged, after: :perform_tag_known_unknown,
          guard: :no_errors?
      end
      event :exit_if_known_unknown do
        transitions from: :known_unknown_tagged, to: :done, guard: :known_unknown?
      end
      event :collapse_tokens do
        transitions from: :known_unknown_tagged, to: :tokens_collapsed, after: :perform_collapse_tokens,
          guard: :no_errors?
      end
      event :convert_months do
        transitions from: :tokens_collapsed, to: :months_converted, after: :perform_convert_months,
          guard: :no_errors?
      end
      event :translate_ordinals do
        transitions from: :months_converted, to: :ordinals_translated, after: :perform_translate_ordinals,
          guard: :no_errors?
      end
      event :certainty_check do
        transitions from: :ordinals_translated, to: :values_certainty_checked, after: :perform_certainty_check,
          guard: :no_errors?
      end
      event :standardize_formats do
        transitions from: :values_certainty_checked, to: :formats_standardized,
          after: :perform_standardize_formats, guard: :no_errors?
      end
      event :tag_date_parts do
        transitions from: :formats_standardized, to: :date_parts_tagged, after: :perform_tag_date_parts,
          guard: :no_errors?
      end
      event :segment_dates do
        transitions from: :date_parts_tagged, to: :dates_segmented, after: :perform_segment_dates,
          guard: :no_errors?
      end
      event :indicate_ranges do
        transitions from: :dates_segmented, to: :indicated_ranges, after: :perform_indicate_ranges,
          guard: :no_errors?
      end
      event :check_final_segments do
        transitions from: :indicated_ranges, to: :final_segments_checked, after: :perform_check_final_segments,
          guard: :no_errors?
      end

      event :finalize do
        transitions from: :tokenized, to: :done, guard: :no_errors?
        transitions from: :tokenized, to: :failed, guard: :errors?
        transitions from: :untokenizable_tagged, to: :done, guard: :no_errors?
        transitions from: :untokenizable_tagged, to: :failed, guard: :errors?
        transitions from: :unprocessable_tagged, to: :done, guard: :no_errors?
        transitions from: :unprocessable_tagged, to: :failed, guard: :errors?
        transitions from: :known_unknown_tagged, to: :done, guard: :no_errors?
        transitions from: :known_unknown_tagged, to: :failed, guard: :errors?
        transitions from: :tokens_collapsed, to: :done, guard: :no_errors?
        transitions from: :tokens_collapsed, to: :failed, guard: :errors?
        transitions from: :months_converted, to: :done, guard: :no_errors?
        transitions from: :months_converted, to: :failed, guard: :errors?
        transitions from: :ordinals_translated, to: :done, guard: :no_errors?
        transitions from: :ordinals_translated, to: :failed, guard: :errors?
        transitions from: :values_certainty_checked, to: :done, guard: :no_errors?
        transitions from: :values_certainty_checked, to: :failed, guard: :errors?
        transitions from: :formats_standardized, to: :done, guard: :no_errors?
        transitions from: :formats_standardized, to: :failed, guard: :errors?
        transitions from: :date_parts_tagged, to: :done, guard: :no_errors?
        transitions from: :date_parts_tagged, to: :failed, guard: :errors?
        transitions from: :dates_segmented, to: :done, guard: :no_errors?
        transitions from: :dates_segmented, to: :failed, guard: :errors?
        transitions from: :indicated_ranges, to: :done, guard: :no_errors?
        transitions from: :indicated_ranges, to: :failed, guard: :errors?
        transitions from: :final_segments_checked, to: :done, guard: :no_errors?
        transitions from: :final_segments_checked, to: :failed, guard: :errors?
      end
    end

    def process
      lex
      tag_untokenizable if may_tag_untokenizable?
      exit_if_untokenizable if may_exit_if_untokenizable?
      tag_unprocessable if may_tag_unprocessable?
      exit_if_unprocessable if may_exit_if_unprocessable?
      tag_known_unknown if may_tag_known_unknown?
      exit_if_known_unknown if may_exit_if_known_unknown?
      collapse_tokens if may_collapse_tokens?
      convert_months if may_convert_months?
      translate_ordinals if may_translate_ordinals?
      certainty_check if may_certainty_check?
      standardize_formats if may_standardize_formats?
      tag_date_parts if may_tag_date_parts?
      segment_dates if may_segment_dates?
      indicate_ranges if may_indicate_ranges?
      finalize if may_finalize?
      prepare_result
    end

    def prep_for(event)
      ready = false
      until ready
        events = aasm.events.map(&:name)
        if events.include?(event)
          ready = true
        else
          next_events = events.select{ |next_event| send("may_#{next_event}?".to_sym) }
          if next_events.empty?
            puts "WARNING: cannot prep for #{event}"
            return
          end
          send(next_events.first)
        end
      end
      finalize
    end

    def state
      aasm.current_state
    end

    def to_s
      <<~OBJ
      #<#{self.class.name}:#{self.object_id}
        @state=#{state},
        token_type_pattern: #{tokens.types.inspect}>
      OBJ
    end
    alias_method :inspect, :to_s
    
    private

    def perform_check_final_segments
      return unless errors.empty?

      tokens.each do |t|
        next if t.date_type?
        next if t.type == :or
        next if t.type == :and

        errors << 'Unhandled segment still present'
      end
    end

    def prepare_result
      state == :failed ? prepare_failed_result : prepare_ok_result
    end

    def prepare_failed_result
      r = { original_string: orig_string,
           errors: errors.map!{ |err| Emendate::ErrorUtil.msg(err).join("\n") },
           warnings: warnings,
           result: []
          }

        @result = Emendate::Result.new(r)
    end

    def prepare_ok_result
      r = { original_string: orig_string,
           errors: errors,
           warnings: warnings,
           result: []
          }

      tokens.segments.each{ |t| r[:result] << Emendate::ParsedDate.new(t, tokens.certainty, orig_string) if t.date_type? }
      @result = Emendate::Result.new(r)
    end

    def perform_lex
      l = Emendate::Lexer.new(norm_string)
      begin
        l.tokenize
      rescue Emendate::UntokenizableError => e
        errors << e
      else
        @norm_string = l.norm
        @tokens = l.tokens
        @orig_tokens = tokens.class.new.copy(tokens)
      end
    end

    def perform_collapse_tokens
      c = Emendate::TokenCollapser.new(tokens: tokens, options: options)
      c.collapse
      @tokens = c.result
      @collapsed_tokens = tokens.class.new.copy(tokens)
    end

    def perform_convert_months
      c = Emendate::AlphaMonthConverter.new(tokens: tokens, options: options)
      c.convert
      @tokens = c.result
      @converted_months = tokens.class.new.copy(tokens)
    end

    def perform_translate_ordinals
      t = Emendate::OrdinalTranslator.new(tokens: converted_months, options: options)
      begin
        t.translate
      rescue StandardError => e
        errors << e
      else
        @tokens = t.result
        @translated_ordinals = tokens.class.new.copy(tokens)
      end
    end

    def perform_certainty_check
      c = Emendate::CertaintyChecker.new(tokens: translated_ordinals, options: options)
      begin
        c.check
      rescue StandardError => e
        errors << e
      else
        @tokens = c.result
        @certainty_checked = tokens.class.new.copy(tokens)
      end
    end

    def perform_standardize_formats
      f = Emendate::FormatStandardizer.new(tokens: tokens, options: options)
      begin
        f.standardize
      rescue StandardError => e
        errors << e
      else
        @tokens = f.result
        @standardized_formats = tokens.class.new.copy(tokens)
      end
    end

    def perform_tag_date_parts
      t = Emendate::DatePartTagger.new(tokens: standardized_formats, options: options)
      begin
        t.tag
      rescue StandardError => e
        errors << e
      else
        @tokens = t.result
        @tagged_date_parts = tokens.class.new.copy(tokens)
      end
    end

    def perform_tag_unprocessable
      t = Emendate::UnprocessableTagger.new(tokens: tagged_untokenizable, str: orig_string)
      begin
        t.tag
      rescue StandardError => e
        errors << e
      else
        @tokens = t.result
        @tagged_unprocessable = tokens.class.new.copy(tokens)
      end
    end

    def perform_tag_untokenizable
      t = Emendate::UntokenizableTagger.new(tokens: tokens, str: orig_string)
      begin
        t.tag
      rescue StandardError => e
        errors << e
      else
        @tokens = t.result
        @tagged_untokenizable = tokens.class.new.copy(tokens)
      end
    end

    def perform_tag_known_unknown
      t = Emendate::KnownUnknownTagger.new(tokens: tokens, str: orig_string, options: options)
      begin
        t.tag
      rescue StandardError => e
        errors << e
      else
        @tokens = t.result
        @tagged_known_unknown = tokens.class.new.copy(tokens)
      end
    end

    def perform_segment_dates
      s = Emendate::DateSegmenter.new(tokens: tagged_date_parts, options: options)
      begin
        s.segment
      rescue StandardError => e
        errors << e
      else
        @tokens = s.result
        @segmented_dates = tokens.class.new.copy(tokens)
      end
    end

    def perform_indicate_ranges
      i = Emendate::RangeIndicator.new(tokens: segmented_dates, options: options)
      begin
        i.indicate
      rescue StandardError => e
        errors << e
      else
        @tokens = i.result
        @ranges_indicated = tokens.class.new.copy(tokens)
      end
    end

    def log_status_change
      # puts "changing from #{aasm.from_state} to #{aasm.to_state} (event: #{aasm.current_event})"
    end

    def gather_warnings
      warnings << tokens.warnings unless tokens.warnings.empty?
      warnings.flatten!
      warnings.uniq!
    end

    def errors?
      !errors.empty?
    end

    def no_errors?
      errors.empty?
    end

    def unprocessable?
      tokens.types == [:unprocessable_date_type]
    end

    def untokenizable?
      tokens.types == [:untokenizable_date_type]
    end

    def known_unknown?
      tokens.types == [:knownunknown_date_type]
    end
  end
end
