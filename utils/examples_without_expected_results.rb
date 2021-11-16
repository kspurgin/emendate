# frozen_string_literal: true

require 'csv'
require 'date'

examples_table = CSV.parse(File.read(File.expand_path('../spec/support/examples.csv')), headers: true)
results_table = CSV.parse(File.read(File.expand_path('../spec/support/expected_emendate_results.csv')), headers: true)

examples = examples_table['examplestring']
result_examples = results_table['examplestring'].uniq

diff = examples - result_examples

if diff.empty?
  puts 'All examples have results specified'
else
  puts diff
end

