# frozen_string_literal: true

require_relative '../error_util'
require_relative 'tester'

module Emendate
  module Examples
    class TestableExample
      class EmptyTestSetError < Emendate::Error; end
      
      attr_reader :rows, :fingerprint, :test_string, :test_options, :test_pattern, :processed, :errors
      def initialize(rows)
        @rows = rows

        fail(EmptyTestSetError.new) if rows.empty?
        
        @fingerprint = rows.first.test_fingerprint
        @test_string = rows.first.test_string
        @test_options = rows.first.test_options
        @test_pattern = rows.first.test_pattern
        @processed = nil
        @errors = {}
        @test_results = {}
      end

      def add_error(testname, err)
        errors.key?(testname) ? @errors[testname] = "#{errors[testname]}|#{err}" : @errors[testname] = err
      end

      def add_test_result(testname, result)
        test_results.key?(testname) ? @test_results[testname] = result : @test_results[testname] = result
      end

      def all_tags
        [tags('data_set'), tags('date_type')].flatten.sort.uniq
      end
      
      def report_error(err)
        puts err.map{ |line| "    #{line}" }
      end
      
      def report_failure
        puts "string: #{test_string} -- opts: #{test_options}"
        errors.each do |test, err|
          puts "  test: #{test}"
          report_error(err)
        end
      end
      
      def run_tests(tests: nil, fail_fast: false)
        reset_test_data unless test_results.empty?
        return unless testable?
        
        to_run = tests ? tests.intersection(runnable_tests) : runnable_tests
        testers = to_run.map{ |test| Examples::Tester.build(test: test, example: self) }
        testers.each do |test|
          test.call
          break if fail_fast && !errors[test.name.to_sym].nil?
        end
      end

      def runnable_tests
        @runnable_tests ||= determine_runnable_tests
      end

      # @param type ['data_set', 'date_type']
      def tags(type)
        meth = "tags_#{type}".to_sym
        rows.map{ |row| row.send(meth) }
          .compact
          .map{ |rowtags| rowtags.split(';') }
          .flatten
          .uniq
          .sort
          .reject{ |val| val.blank? }
          .map{ |val| "#{val} (#{meth})" }
      end
      
      def test_status
        return :no_tests_run if test_results.empty?
        
        test_results.values.any?(:failure) ? :failure : :success
      end
      
      def testable?
        @processed ? true : check_testable
      end

      def to_s
        <<~OBJ
        #<#{self.class.name}:#{self.object_id}
          @fingerprint: "#{fingerprint}",
          @rows: #{rows.length},
          @runnable_tests: #{runnable_tests.inspect},
          @processed: #{processed.class.name},
          @test_results: #{test_results.inspect},
          @errors: #{errors.inspect}>
        OBJ
      end
      alias_method :inspect, :to_s

      def type_pattern(date_only: false, stage: :tokens)
        return [:date_string_not_processed] unless testable?
        
        date_only ? processed.send(stage).date_part_types : processed.send(stage).types
      end
      
      private

      attr_reader :test_results
      
      def check_testable
        opt = test_options ? instance_eval("{#{test_options}}") : {}
        processor = Emendate.process(test_string, opt)
      rescue => err
        add_error(:process, Emendate::ErrorUtil.msg(err))
        add_test_result(:process, :failure)
        false
      else
        @processed = processor
        true
      end

      def determine_runnable_tests
        runnables = rows.map(&:runnable_tests)
        return runnables.flatten if runnables.length == 1

        runnables.shift.intersection(*runnables)
      end

      def reset_test_data
        @processed = nil
        @errors = {}
        @test_results = {}
      end
    end
  end
end
