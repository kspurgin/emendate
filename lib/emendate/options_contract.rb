# frozen_string_literal: true

require 'dry-validation'

module Emendate
  class OptionsContract < Dry::Validation::Contract
    schema do
      config.validate_keys = true

      optional(:ambiguous_month_day).value(:symbol)
      optional(:ambiguous_month_day_year).value(:symbol)
      optional(:ambiguous_month_year).value(:symbol)
      optional(:ambiguous_year_rollback_threshold).value(:integer)
      optional(:bce_handling).value(:symbol)
      optional(:before_date_treatment).value(:symbol)
      optional(:beginning_hyphen).value(:symbol)
      optional(:edtf).value(:bool)
      optional(:ending_hyphen).value(:symbol)
      optional(:ending_slash).value(:symbol)
      optional(:max_output_dates).value(:integer)
      optional(:max_month_number_handling).value(:symbol)
      optional(:open_unknown_end_date).value(:string)
      optional(:open_unknown_start_date).value(:string)
      optional(:pluralized_date_interpretation).value(:symbol)
      optional(:square_bracket_interpretation).value(:symbol)
      optional(:dialect).value(:symbol)
      optional(:two_digit_year_handling).value(:symbol)
      optional(:unknown_date_output).value(:symbol)
      optional(:unknown_date_output_string).value(:string)
    end

    rule(:ambiguous_month_day) do
      if key?
        allowed = %i[as_month_day as_day_month]
        val = values[:ambiguous_month_day]
        key.failure(unknown_val_msg(val, allowed)) unless allowed.any?(val)
      end
    end

    rule(:ambiguous_month_day_year) do
      if key?
        allowed = %i[month_day_year day_month_year year_month_day year_day_month]
        val = values[:ambiguous_month_day_year]
        key.failure(unknown_val_msg(val, allowed)) unless allowed.any?(val)
      end
    end

    rule(:ambiguous_month_year) do
      if key?
        allowed = %i[as_year as_month]
        val = values[:ambiguous_month_year]
        key.failure(unknown_val_msg(val, allowed)) unless allowed.any?(val)
      end
    end

    rule(:ambiguous_year_rollback_threshold) do
      if key?
        val = values[:ambiguous_year_rollback_threshold]
        key.failure('must be 0-99') unless val < 100
      end
    end

    rule(:bce_handling) do
      if key?
        allowed = %i[naive precise]
        val = values[:bce_handling]
        key.failure(unknown_val_msg(val, allowed)) unless allowed.any?(val)
      end
    end

    rule(:before_date_treatment) do
      if key?
        allowed = %i[point range]
        val = values[:before_date_treatment]
        key.failure(unknown_val_msg(val, allowed)) unless allowed.any?(val)
      end
    end

    rule(:beginning_hyphen) do
      if key?
        allowed = %i[unknown edtf open]
        val = values[:beginning_hyphen]
        key.failure(unknown_val_msg(val, allowed)) unless allowed.any?(val)
      end
    end

    rule(:ending_hyphen) do
      if key?
        allowed = %i[unknown open]
        val = values[:ending_hyphen]
        key.failure(unknown_val_msg(val, allowed)) unless allowed.any?(val)
      end
    end

    rule(:ending_slash) do
      if key?
        allowed = %i[open unknown]
        val = values[:ending_slash]
        key.failure(unknown_val_msg(val, allowed)) unless allowed.any?(val)
      end
    end

    rule(:max_month_number_handling) do
      if key?
        allowed = %i[months edtf_level_1 edtf_level_2]
        val = values[:max_month_number_handling]
        key.failure(unknown_val_msg(val, allowed)) unless allowed.any?(val)
      end
    end

    rule(:pluralized_date_interpretation) do
      if key?
        allowed = %i[decade broad]
        val = values[:pluralized_date_interpretation]
        key.failure(unknown_val_msg(val, allowed)) unless allowed.any?(val)
      end
    end

    rule(:square_bracket_interpretation) do
      if key?
        allowed = %i[inferred_date edtf_set]
        val = values[:square_bracket_interpretation]
        key.failure(unknown_val_msg(val, allowed)) unless allowed.any?(val)
      end
    end

    rule(:dialect) do
      if key?
        allowed = %i[lyrasis_pseudo_edtf edtf collectionspace]
        val = values[:dialect]
        key.failure(unknown_val_msg(val, allowed)) unless allowed.any?(val)
      end
    end

    rule(:two_digit_year_handling) do
      if key?
        allowed = %i[coerce literal]
        val = values[:two_digit_year_handling]
        key(:two_digit_year_handling).failure(unknown_val_msg(val, allowed)) unless allowed.any?(val)
      end
    end

    rule(:unknown_date_output) do
      if key?
        allowed = %i[orig custom]
        val = values[:unknown_date_output]
        key.failure(unknown_val_msg(val, allowed)) unless allowed.any?(val)
      end
    end

    rule(:open_unknown_end_date) do
      if key?
        str = values[:open_unknown_end_date]
        result = test_date_string(str)
        key.failure(date_failure_msg(str)) unless result == :success
      end
    end

    rule(:open_unknown_start_date) do
      if key?
        str = values[:open_unknown_start_date]
        result = test_date_string(str)
        key.failure(date_failure_msg(str)) unless result == :success
      end
    end

    private

    def test_date_string(str)
      Date.parse(str)
    rescue
      :failure
    else
      :success
    end

    def date_failure_msg(str)
      "value #{str} cannot be parsed into a valid date. Use a date string in the "\
        "format: YYYY-MM-DD"
    end

    def unknown_val_msg(val, allowed)
      ":#{val} is not an allowed value. Use one of: #{allowed.map{ |val| ":#{val}" }.join(', ')}"
    end
  end
end
