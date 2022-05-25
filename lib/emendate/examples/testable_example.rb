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
      @messages = {}
    end

    def add_error(testname, err)
      errors.key?(testname) ? @errors[testname] << err : @errors[testname] = [err].flatten
    end

    def run_tests(tests: nil, fail_fast: true)
      return unless testable?
      
      to_run = tests ? tests : runnable_tests
      testers = to_run.map{ |test| Examples::Tester.build(test: test, example: self) }
    end
    
    def runnable_tests
      runnables = rows.map(&:runnable_tests)
      return runnables.flatten if runnables.length == 1

      runnables.shift.intersection(*runnables)
    end

    def testable?
      @processed ? true : check_testable
    end

    private

    def check_testable
      opt = test_options ? test_options : {}
      processor = Emendate.process(test_string, opt)
    rescue => err
      err_msg = err.backtrace.first(3).join('|||')
      add_error(:process, err_msg)
      false
    else
      @processed = processor.result
      true
    end
  end
end
