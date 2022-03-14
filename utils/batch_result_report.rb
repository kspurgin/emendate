# frozen_string_literal: true

require 'csv'
require 'optparse'

require 'bundler/setup'
require 'emendate'
require 'pry'

options = {}
OptionParser.new{ |opts|
  opts.banner = 'Usage: ruby batch_result_report.rb -i {input_csv}'

  opts.on('-i', '--input INPUTPATH', 'Path to csv file containing examples'){ |i|
    options[:input] = i
    unless File::exist?(i)
      puts "Not a valid input file: #{i}"
      exit
    end
  }
  opts.on('-h', '--help', 'Prints this help'){
    puts opts
    exit
  }
}.parse!

outfile = options[:input].sub('.csv', '_report.csv')
headers = %i[orig errs warnings date_ct start_full end_full certainty range]

CSV.open(outfile, 'wb') do |csvout|
  csvout << headers

  CSV.foreach(options[:input]) do |row|
    val = row.first.strip
    puts val

    processor = Emendate.process(val)

    prep = { orig: val }
    prep[:errs] = processor.errors.join('; ') unless processor.errors.empty?
    prep[:warnings] = processor.warnings.join('; ') unless processor.warnings.empty?

    if processor.errors.empty?
      unless processor.result.dates.empty?
        prep[:date_ct] = processor.result.date_count
        prep[:certainty] = processor.result.compile_date_info(method: :certainty, delim: '; ')
        prep[:start_full] = processor.result.compile_date_info(method: :date_start_full, delim: '; ')
        prep[:end_full] = processor.result.compile_date_info(method: :date_end_full, delim: '; ')
        prep[:range] = processor.result.compile_date_info(method: :inclusive_range, delim: '; ')
      end
    end

    csvout << prep.values_at(*headers)
  end
end

