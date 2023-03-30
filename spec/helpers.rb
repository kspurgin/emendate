# frozen_string_literal: true

require 'emendate'

module Helpers
  module_function

  def processing_steps
    {
      Emendate::Lexer =>
        ->(string){ Emendate::Lexer.call(string) },
      Emendate::UntokenizableTagger =>
        ->(tokens){ Emendate::UntokenizableTagger.call(tokens) },
      Emendate::UnprocessableTagger =>
        ->(tokens){ Emendate::UnprocessableTagger.call(tokens) },
      Emendate::KnownUnknownTagger =>
        ->(tokens){ Emendate::KnownUnknownTagger.call(tokens) },
      Emendate::TokenCollapser =>
        ->(tokens){ Emendate::TokenCollapser.call(tokens) },
      Emendate::AlphaMonthConverter =>
        ->(tokens){ Emendate::AlphaMonthConverter.call(tokens) },
      Emendate::OrdinalTranslator =>
        ->(tokens){ Emendate::OrdinalTranslator.call(tokens) },
      Emendate::CertaintyChecker =>
        ->(tokens){ Emendate::CertaintyChecker.call(tokens) },
      Emendate::FormatStandardizer =>
        ->(tokens){ Emendate::FormatStandardizer.call(tokens) },
      Emendate::DatePartTagger =>
        ->(tokens){ Emendate::DatePartTagger.call(tokens) },
      Emendate::DateSegmenter =>
        ->(tokens){ Emendate::DateSegmenter.call(tokens) },
      Emendate::RangeIndicator =>
        ->(tokens){ Emendate::RangeIndicator.call(tokens) }
    }
  end

  def prep_steps(step)
    keys = processing_steps.keys
    target_idx = keys.find_index(step)
    return unless target_idx
    return if target_idx == 0

    keys[0..(target_idx - 1)]
  end

  # @param string [String] original date string
  # @param target [Class] class you need input for
  def prepped_for(string:, target:)
    to_prep =  prep_steps(target)
    return string unless to_prep

    tokens = to_prep.first
      .call(string)
      .value!

    return tokens if to_prep.length == 1

    to_prep.shift
    to_prep.each do |step|
      tokens = step.call(tokens)
        .value!
    end

    tokens
  end

  def test_rows(str, opt)
    Emendate::Examples::Csv.rows(str, opt)
      .sort_by{ |row| row.dateval_occurrence }
  end
end
