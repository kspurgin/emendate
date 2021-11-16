require 'bundler/setup'
require 'emendate'
require 'csv'

# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
# variables to change per usage
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
input_csv = '~/data/input.csv'
output_csv = '~/data/output.csv'
date_column = 'orig_date_value'
dialect = :lyrasis_pseudo_edtf
max_dates = 1
month_year = :as_year
known_unknown = 'not dated'
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

options = {
  target_dialect: dialect,
  max_output_dates: max_dates,
  unknown_date_output: :custom,
  unknown_date_output_string: 'not dated',
  ambiguous_month_year: :as_year 
}

def get_headers(input)
  ct = 0
  headers = nil
  CSV.foreach(input) do |row|
    headers = row
    ct += 1
    break if ct > 0
  end
  headers
end

input = File.expand_path(input_csv)
output = File.expand_path(output_csv)
orig_headers = get_headers(input)
extra_headers = orig_headers - [date_column]
headers = orig_headers + %w[date_result date_processing_warnings]

CSV.open(output, 'w', headers: headers, write_headers: true) do |csv|
  CSV.foreach(input, headers: true) do |row|
    new_row = []
    orig_headers.each{ |hdr| new_row << row[hdr] }
    orig_date = row[date_column]

    if orig_date.blank?
      date_result = ''
      warnings = []
    else

      begin
        result = Emendate.translate(orig_date, options)
      rescue => err
        date_result = ''
        warnings = [err]
      else
        date_result = result.value
        warnings = result.warnings
      end
      
    end

    new_row << date_result
    new_row << warnings.join('; ')
    csv << new_row
  end
end
