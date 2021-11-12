# frozen_string_literal: true

require 'csv'
require_relative 'row'
require_relative 'test'

module Examples
  class ExampleSet
    attr_reader :data_sets, :date_types, :tests
    
    def initialize(data_set: '', date_type: '')
      table = CSV.parse(File.read(File.expand_path(Path)), headers: true)
      @data_set_tags = data_set.split(';').sort
      @date_type_tags = date_type.split(';').sort
      allrows = []
      table.each{ |row| allrows << Row.new(row) }
      @rows = specified_rows(allrows)
      @data_sets = @rows.map{ |row| row.data_sets }.flatten.uniq.sort
      @date_types = @rows.map{ |row| row.date_types }.flatten.uniq.sort
      @tests = @rows.group_by{ |row| row.test_fingerprint }.map{ |_str, ary| Test.new(ary) }
    end

    def brief_report
      tests.each{ |test| puts test.brief_report }
      puts ''
      pass_fail_summary
    end
    
    def run_tests(test_list: nil, fail_fast: true)
      if test_list
        tests.each{ |test| test.run(tests: test_list, fail_fast: fail_fast) }
      else
        tests.each{ |test| test.run(fail_fast: fail_fast) }
      end
    end
    
    def strings
      @rows.map{ |row| row.string }.uniq.sort
    end

    def unique_example_strings
      table['examplestring'].uniq.sort
    end

    def group_by_pass_fail
      hash = tests.group_by{ |test| test.failure? }
      { passes: hash[false], failures: hash[true] }
    end

    def pass_fail_summary
      group_by_pass_fail.each{ |cat, results| puts "#{cat.upcase}: #{results.length}" }
    end
    
    private

    def specified_dataset(rows)
      return rows if @data_set_tags.empty?

      rows.select{ |row| row.tagged?(type: :data_sets, tags: @data_set_tags) }
    end

    def specified_datetype(rows)
      return rows if @date_type_tags.empty?

      rows.select{ |row| row.tagged?(type: :date_types, tags: @date_type_tags) }
    end

    def specified_rows(rows)
      dataset_rows = specified_dataset(rows)
      return dataset_rows if dataset_rows.empty?

      specified_datetype(dataset_rows)
    end
    
    def string_plus_options(row)
      "#{row['examplestring']} #{row['options']}"
    end
  end
end
