# frozen_string_literal: true

require 'emendate'

module Helpers
  module_function

  def processing_steps
    {
      Emendate::Lexer =>
        ->(string){ Emendate::Lexer.call(string) },
      Emendate::UntokenizableTagger =>
        ->(lexed, string) do
        Emendate::UntokenizableTagger.call(tokens: lexed, str: string)
      end
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

    fail(StandardError, 'finish me')
  end

  def test_rows(str, opt)
    Emendate::Examples::Csv.rows(str, opt)
      .sort_by{ |row| row.dateval_occurrence }
  end
end
