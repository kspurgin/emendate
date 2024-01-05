# frozen_string_literal: true

require 'csv'
require 'optparse'

require 'bundler/setup'
require 'emendate'
require 'pry'

options = {}
OptionParser.new{ |opts|
  opts.banner = 'Usage: ruby translate_to_cspace_csv.rb -i {input_csv}'

  opts.on('-i', '--input PATH', 'Path to csv file containing date_strings'){ |i|
    options[:input] = i
    unless File::exist?(i)
      puts "Not a valid input file: #{i}"
      exit
    end
  }
  opts.on(
    '-o',
    '--optargs OPTARGS',
    'Options hash, in curly brackets, in quotes'
  ){ |o|
    optargs = to_h(o)
    if optargs == :cannot_eval
      puts "Cannot parse options to Hash.\nEnter wrapped in quotes and curly "\
        "brackets like:\n"\
        "\"{my_option: option_value}\""
      exit
    else
      Emendate::Options.new(optargs)
      options[:optargs] = optargs.merge({dialect: :collectionspace})
    end
  }
  opts.on('-h', '--help', 'Prints this help'){
    puts opts
    exit
  }
}.parse!

outfile = options[:input].sub('.csv', '_translated.csv')
HEADERS = %i[orig warnings
             dateDisplayDate datePeriod dateAssociation dateNote
             dateEarliestSingleYear dateEarliestSingleMonth
             dateEarliestSingleDay dateEarliestSingleEra
             dateEarliestSingleCertainty dateEarliestSingleQualifier
             dateEarliestSingleQualifierValue dateEarliestSingleQualifierUnit
             dateLatestYear dateLatestMonth dateLatestDay dateLatestEra
             dateLatestCertainty dateLatestQualifier dateLatestQualifierValue
             dateLatestQualifierUnit dateEarliestScalarValue
             dateLatestScalarValue scalarValuesComputed]

CSV.open(outfile, 'wb') do |csvout|
  csvout << HEADERS
end

strings = CSV.foreach(options[:input]).map{ |row| row.first.strip }
optargs = options[:optargs] ||= {dialect: :collectionspace}

# @param row [Hash]
def pad_row(row)
  missing = HEADERS - row.keys
  row.merge(missing.map{ |field| [field, nil] }.to_h)
end

# @param translated [Hash] single values element from translation
# @param translation [Emendate::Translation]
# @param idx [Integer]
def create_row(translated, translation, idx)
    row = { orig: translation.orig }.merge(translated)
    unless translation.warnings[idx].empty?
      row[:warnings] = translation.warnings.join('; ')
    end
    pad_row(row)
end

CSV.open(outfile, 'a') do |csvout|
  Emendate.batch_translate(strings, optargs) do |translation|
    translation.values.each_with_index do |translated, idx|
      row = create_row(translated, translation, idx)
      csvout << row.values_at(*HEADERS)
    end
  end
end