# frozen_string_literal: true

require "csv"
require "optparse"

require "bundler/setup"
require "emendate"
require "pry"

def to_h(hash_as_string)
  h = instance_eval(hash_as_string)
rescue SyntaxError
  :cannot_eval
else
  h.is_a?(Hash) ? h : :cannot_eval
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: ruby batch_result_report.rb -i {input_csv}"

  opts.on("-i", "--input INPUTPATH",
    "Path to csv file containing examples") do |i|
    options[:input] = i
    unless File.exist?(i)
      puts "Not a valid input file: #{i}"
      exit
    end
  end
  opts.on(
    "-o",
    "--optargs OPTARGS",
    "Options hash, in curly brackets, in quotes"
  ) do |o|
    optargs = to_h(o)
    if optargs == :cannot_eval
      puts "Cannot parse options to Hash.\nEnter wrapped in quotes and curly "\
        "brackets like:\n"\
        "\"{my_option: option_value}\""
      exit
    else
      Emendate::Options.new(optargs)
      options[:optargs] = optargs
    end
  end
  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
end.parse!

outfile = options[:input].sub(".csv", "_report.csv")
headers = %i[orig errs warnings date_ct start_full end_full certainty range
  types]

CSV.open(outfile, "wb") do |csvout|
  csvout << headers
end

strings = CSV.foreach(options[:input]).map { |row| row.first.strip }
optargs = options[:optargs] ||= {}

CSV.open(outfile, "a") do |csvout|
  Emendate.batch_process(strings, optargs) do |processor|
    prep = {orig: processor.orig_string}
    prep[:errs] = processor.errors.join("; ") unless processor.errors.empty?
    unless processor.warnings.empty?
      prep[:warnings] =
        processor.warnings.join("; ")
    end

    if processor.errors.empty?
      unless processor.result.dates.empty?
        prep[:date_ct] = processor.result.date_count
        prep[:certainty] = processor.result
          .dates
          .map { |date| date.qualifiers.map(&:for_test).join(";") }
        prep[:start_full] =
          processor.result.compile_date_info(method: :date_start_full,
            delim: "; ")
        prep[:end_full] =
          processor.result.compile_date_info(method: :date_end_full,
            delim: "; ")
        prep[:range] =
          processor.result.compile_date_info(method: :inclusive_range,
            delim: "; ")
        prep[:types] = processor.tokens.map(&:type).join(" ")
      end
    end
    csvout << prep.values_at(*headers)
  end
end
