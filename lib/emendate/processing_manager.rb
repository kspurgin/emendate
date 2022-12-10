# frozen_string_literal: true

require_relative 'error_util'

module Emendate
  class ProcessingManager
    include Dry::Monads[:result]
    include Dry::Monads::Do.for(:call)

    class << self
      def call(...)
        self.initialize(...).call
      end
    end

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
      :errors, :warnings

    def initialize(string, options = {})
      @orig_string = string
      Emendate::Options.new(options) unless options.empty?
      @options = options
      @norm_string = Emendate.normalize_orig(orig_string)
      @tokens = Emendate::SegmentSets::TokenSet.new
      @errors = []
      @warnings = []
    end

    def call
      @norm_string = yield Emendate.normalize(orig_string)

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

    def result
      Emendate::Result.new(self)
    end

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

    def perform_lex
      l = Emendate::Lexer.new(norm_string)
      l.tokenize
      @norm_string = l.norm
      @tokens = l.tokens
      @orig_tokens = tokens.class.new.copy(tokens)
    end

    def perform_collapse_tokens
      c = Emendate::TokenCollapser.new(tokens: tokens)
      c.collapse
      @tokens = c.result
      @collapsed_tokens = tokens.class.new.copy(tokens)
    end

    def perform_convert_months
      c = Emendate::AlphaMonthConverter.new(tokens: tokens)
      c.convert
      @tokens = c.result
      @converted_months = tokens.class.new.copy(tokens)
    end

    def perform_translate_ordinals
      t = Emendate::OrdinalTranslator.new(tokens: converted_months)
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
      c = Emendate::CertaintyChecker.new(tokens: translated_ordinals)
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
      f = Emendate::FormatStandardizer.new(tokens: tokens)
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
      t = Emendate::DatePartTagger.new(tokens: standardized_formats)
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
      t = Emendate::KnownUnknownTagger.new(tokens: tokens, str: orig_string)
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
      s = Emendate::DateSegmenter.new(tokens: tagged_date_parts)
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
      i = Emendate::RangeIndicator.new(tokens: segmented_dates)
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
