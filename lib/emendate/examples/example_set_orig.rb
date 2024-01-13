# frozen_string_literal: true
# # frozen_string_literal: true

# require 'csv'
# require_relative 'row'
# require_relative 'test'

# module Examples
#   class ExampleSet
#     attr_reader :data_sets, :date_types, :tests

#     def initialize(data_set: '', date_type: '')
#       table = CSV.parse(File.read(File.expand_path(Path)), headers: true)
#       @data_set_tags = data_set.split(';').sort
#       @date_type_tags = date_type.split(';').sort
#       allrows = table.map{ |row| Row.new(row) }
#       @rows = specified_rows(allrows)
#       @data_sets = @rows.map{ |row| row.data_sets }.flatten.uniq.sort
#       @date_types = @rows.map{ |row| row.date_types }.flatten.uniq.sort
#       @tests = @rows.group_by{ |row| row.test_fingerprint }.map{ |_str, ary| Test.new(ary) }
#     end

#     def brief_report
#       tests.each{ |test| puts test.brief_report }
#       puts ''
#       pass_fail_summary
#     end

#     def list_by_test_fingerprint
#       rows.group_by{ |row| row.test_string }
#         .each{ |pattern, row_array| put_grouped_rows(pattern, row_array, :test_options) }
#       ''
#     end

#     def list_by_pattern
#       rows.group_by{ |row| row.test_pattern }
#         .each{ |pattern, row_array| put_grouped_rows(pattern, row_array, :test_string) }
#       ''
#     end

#     def list_runnable_tests
#       puts runnable_tests
#     end

#     def list_strings
#       puts strings
#     end

#     def run_tests(test_list: nil, fail_fast: true)
#       if test_list
#         tests.each{ |test| test.run(tests: test_list, fail_fast: fail_fast) }
#       else
#         tests.each{ |test| test.run(fail_fast: fail_fast) }
#       end
#     end

#     def strings
#       @rows.map{ |row| row.test_string }.uniq.sort
#     end

#     def unique_example_strings
#       table['test_string'].uniq.sort
#     end

#     def group_by_pass_fail
#       hash = tests.group_by{ |test| test.failure? }
#       { passes: hash[false], failures: hash[true] }.compact
#     end

#     def pass_fail_summary
#       group_by_pass_fail.each{ |cat, results| puts "#{cat.upcase}: #{results.length}" }
#     end

#     def runnable_tests
#       tests.map(&:runnable_tests).flatten.uniq
#     end

#     def to_s
#       "#{tests.length} examples (from #{@rows.length} rows)"
#     end
#     alias_method :inspect, :to_s

#     private

#     attr_reader :rows

#     def put_grouped_rows(key, row_array, to_put)
#       puts key
#       puts row_array.map{ |row| "  #{row.send(to_put)}" }.uniq.sort
#     end

#     def specified_dataset(row_array)
#       return row_array if @data_set_tags.empty?

#       row_array.select{ |row| row.tagged?(type: :data_sets, tags: @data_set_tags) }
#     end

#     def specified_datetype(row_array)
#       return row_array if @date_type_tags.empty?

#       row_array.select{ |row| row.tagged?(type: :date_types, tags: @date_type_tags) }
#     end

#     def specified_rows(row_array)
#       dataset_rows = specified_dataset(row_array)
#       return dataset_rows if dataset_rows.empty?

#       specified_datetype(dataset_rows)
#     end

#     def string_plus_options(row)
#       "#{row['examplestring']} #{row['options']}"
#     end
#   end
# end
