# frozen_string_literal: true

require 'csv'
require 'optparse'

require 'bundler/setup'
require 'emendate'

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

    result = Emendate.process(val)

    prep = {orig: val}
    prep[:errs] = result.errors.join('; ') unless result.errors.empty?
    prep[:warnings] = result.warnings.join('; ') unless result.warnings.empty?

    if result.errors.empty?
      unless result.result[:result].empty?
        prep[:date_ct] = result.result[:result].length
        prep[:certainty] = result.result[:result].map{ |r| r[:certainty].join(', ') }.join('; ')
        prep[:start_full] = result.result[:result].map{ |r| r[:date_start_full] }.join('; ')
        prep[:end_full] = result.result[:result].map{ |r| r[:date_end_full] }.join('; ')
        prep[:range] = result.result[:result].map{ |r| r[:inclusive_range] }.join('; ')
      end
    end

    csvout << prep.values_at(*headers)
  end
end

