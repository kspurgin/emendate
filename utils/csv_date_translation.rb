# frozen_string_literal: true

require "bundler/setup"
require "emendate"
require "csv"

# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# variables to change per usage
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
input_csv = "~/data/az_ccp/mig/working/obj_dates_all_uniq.csv"
output_csv = "~/data/az_ccp/mig/supplied/obj_dates_translated.csv"
date_column = "date_value"

options = {
  ambiguous_month_year: :as_month,
  dialect: :collectionspace,
  max_output_dates: 1,
  unknown_date_output: :orig,
  unknown_date_output_string: ""
}
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

def get_headers(input)
  CSV.parse_line(File.open(input), headers: true)
    .headers
    .map(&:to_sym)
end

def dialect_headers(options)
  case options[:dialect]
  when :collectionspace
    %i[dateDisplayDate datePeriod dateAssociation dateNote
      dateEarliestSingleYear dateEarliestSingleMonth
      dateEarliestSingleDay dateEarliestSingleEra
      dateEarliestSingleCertainty dateEarliestSingleQualifier
      dateEarliestSingleQualifierValue dateEarliestSingleQualifierUnit
      dateLatestYear dateLatestMonth dateLatestDay dateLatestEra
      dateLatestCertainty dateLatestQualifier dateLatestQualifierValue
      dateLatestQualifierUnit dateEarliestScalarValue
      dateLatestScalarValue scalarValuesComputed]
  else
    [:date_result]
  end
end

def target_for_orig_when_error(options)
  case options[:dialect]
  when :collectionspace
    :dateDisplayDate
  else
    :date_result
  end
end

input = File.expand_path(input_csv)
output = File.expand_path(output_csv)
orig_headers = get_headers(input)
extra_headers = orig_headers - [date_column.to_sym]
headers = [date_column.to_sym, :warnings, dialect_headers(options),
  extra_headers].flatten

CSV.open(output, "w", headers: headers, write_headers: true) do |csv|
  CSV.foreach(input, headers: true) do |inrow|
    orig_date = inrow[date_column]
    next if orig_date.blank?

    base = {date_column.to_sym => orig_date}
    extra_headers.each { |e_hdr| base[e_hdr] = inrow[e_hdr.to_s] }
    if options[:dialect] == :collectionspace
      base[:scalarValuesComputed] =
        "false"
    end

    begin
      translation = Emendate.translate(orig_date, options)
    rescue => err
      row = base.merge do
        target_for_orig_when_error(options) => orig_date,
          :warnings => err
      end
      csv << row.values_at(*headers)
    else
      base[:warnings] = translation.warnings.join("; ")
      translation.values.each do |value|
        row = if options[:dialect] == :collectionspace
          base.merge(value)
        else
          base.merge do
            dialect_headers(options).first => value
          end
        end
        csv << row.values_at(*headers)
      end
    end
  end
end
