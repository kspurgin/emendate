# frozen_string_literal: true

require_relative 'taggable'
require_relative 'row_set'
require_relative 'testable_example'

module Examples
  # Basically just a holder for a list of Examples::TestableExample objects, with some convenience
  #   methods
  class ExampleSet
    include Examples::Taggable
    
    attr_reader :examples
    
    def initialize(data_sets: '', date_types: '')
      @rows = Examples::RowSet.new(data_sets: data_sets, date_types: date_types)
        .rows
        .sort_by{ |row| row.dateval_occurrence }
      set_up_tags(data_sets, date_types)
      
      @examples = @rows.group_by{ |row| row.test_fingerprint }
        .values
        .map{ |rows| Examples::TestableExample.new(rows) }
    end

    def failures
      grouped_by_test_status[:failure]
    end
    
    def run_tests(tests: nil, fail_fast: true)
      to_run = tests ? tests.intersection(runnable_tests) : runnable_tests
      examples.each{ |example| example.run_tests(tests: to_run, fail_fast: fail_fast) }
    end
    
    def runnable_tests
      @runnable_tests ||= determine_runnable_tests
    end

    def successs
      grouped_by_test_status[:success]
    end
    
    def to_s
      "#{examples.length} examples from #{rows.length} rows #{tags_to_s}"
    end
    alias_method :inspect, :to_s
    
    private

    attr_reader :rows

    def determine_runnable_tests
      examples.map(&:runnable_tests).flatten.sort.uniq
    end

    def grouped_by_test_status
      @grouped_by_test_status ||= examples.group_by{ |example| example.test_status }
    end
  end
end
