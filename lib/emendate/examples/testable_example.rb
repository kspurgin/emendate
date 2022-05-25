# frozen_string_literal: true

require_relative 'tester'

module Examples
  class TestableExample
    class EmptyTestSetError < Emendate::Error; end
      
    attr_reader :rows, :fingerprint, :test_string, :test_options, :processed, :errors
    def initialize(rows)
      @rows = rows

      fail(EmptyTestSetError.new) if rows.empty?
      
      @fingerprint = rows.first.test_fingerprint
      @test_string = rows.first.test_string
      @test_options = rows.first.test_options
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
    
    def run_tests(tests: nil, fail_fast: true)
      return unless testable?
      
      to_run = tests ? tests.intersection(runnable_tests) : runnable_tests
      testers = to_run.map{ |test| Examples::Tester.build(test: test, example: self) }
      testers.each do |test|
        test.call
        if fail_fast
          break unless errors[test.name.to_sym].nil?
        end
      end
    end

    def runnable_tests
      @runnable_tests ||= determine_runnable_tests
    end

    def test_status
      return :no_tests_run if test_results.empty?
      
      test_results.values.any?(:failure) ? :failure : :success
    end
    
    def testable?
      @processed ? true : check_testable
    end

    private

    attr_reader :test_results
    
    def check_testable
      opt = test_options ? instance_eval("{#{test_options}}") : {}
      processor = Emendate.process(test_string, opt)
    rescue => err
      err_msg = [err.message, err.backtrace.first(3)].flatten
      add_error(:process, err_msg)
      add_test_result(:process, :failure)
      false
    else
      @processed = processor.result
      true
    end

    def determine_runnable_tests
      runnables = rows.map(&:runnable_tests)
      return runnables.flatten if runnables.length == 1

      runnables.shift.intersection(*runnables)
    end
  end
end
