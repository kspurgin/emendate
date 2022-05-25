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

    def not_run
      grouped_by_test_status[:no_tests_run]
    end

    def report_failures
      return if failures.empty?

      puts "\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
      puts 'FAILURES'
      puts '-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'
      failures.each{ |failure| failure.report_failure }
    end

    def report_fingerprint(type)
      array = send(type)
      return if array.blank?
      
      puts "\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
      puts type.to_s.upcase
      puts '-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'
      array.each{ |example| puts example.fingerprint }
    end

    def summary
      puts "\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
      puts 'SUMMARY'
      puts '-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'

      str = %i[successes failures not_run].map{ |meth| [meth, send(meth)] }
        .to_h
        .compact
        .map{ |meth, vals| "#{vals.length} #{meth.to_s}" }
        .join(' -- ')
      puts str
    end
    
    def run_tests(tests: nil, fail_fast: true)
      to_run = tests ? tests.intersection(runnable_tests) : runnable_tests
      examples.each{ |example| example.run_tests(tests: to_run, fail_fast: fail_fast) }
      report_fingerprint(:successes)
      report_fingerprint(:not_run)
      report_failures
      puts summary
    end
    
    def runnable_tests
      @runnable_tests ||= determine_runnable_tests
    end

    def successes
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
