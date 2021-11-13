# frozen_string_literal: true

module Examples
  class Test
    attr_reader :string, :pattern, :options, :result, :messages
    def initialize(rows)
      @rows = rows.sort_by!{ |row| row.occurrence }
      @string = rows.first.string
      @pattern = rows.first.pattern
      @options = rows.first.options
      @errors = []
      @messages = []
      process
      @tests_run = []
      @test_results = []
    end

    def run(tests: all_tests, fail_fast: true)
      test_processing
      return if tests.empty?
      return unless @processable
      
      tests.each do |test|
        break if failure? && fail_fast
        method(test).call
      end
    end

    def brief_report
      "#{string} | #{result_string} (tests: #{@tests_run.join(', ')})"
    end

    def full_report
      padded_messages = @messages.map{ |msg| "      #{msg}" }
      <<~REP
      #{result_string}: #{string}
          Tests run: #{@tests_run.join('; ')}
          Messages:
      #{padded_messages.join("\n")}

      REP
    end

    def failure?
      @test_results.any?(:fail)
    end
    
    def success?
      !failure?
    end
    
    private

    def result_string
      success? ? 'PASS' : 'FAIL'
    end

    def actual_date_vals(method)
      dates = result.result.dates
      return [nil] if dates.empty?
      
      dates.map{ |date| date.method(method).call }
    end

    def actual_val(method)
      result.result.method(method).call
    end
    
    def all_tests
      %i[test_date_start_full test_date_end_full
         test_warnings]
    end

    def expected_date_vals(method)
      @rows.map{ |row| row.method(method).call }
    end

    def expected_val(method)
      @rows.map{ |row| row.method(method).call }.flatten.uniq
    end
    
    def option_call
      "Emendate.process('#{string}', #{options})"
    end
    
    def optionless_call
      "Emendate.process('#{string}')"
    end

    def process
      r = result
    rescue => err
      @errors << err.full_message
      @processable = false
    else
      @result = r
      @processable = true
    end

    def result
      return instance_eval(optionless_call) unless options

      instance_eval(option_call)
    end

    def test_runner(type:, test:, method:)
      @tests_run << test
      got = type == :date ? actual_date_vals(method) : actual_val(method)
      exp = type == :date ? expected_date_vals(method) : expected_val(method)
      if got == exp
        @test_results << :pass
        return
      end

      @test_results << :fail
      @messages << "#{method}: EXPECTED: #{exp.join('|')}, GOT: #{got.join('|')}"
    end

    def test_date_end_full
      test_runner(type: :date, test: __method__, method: :date_end_full)
    end

    def test_date_start_full
      test_runner(type: :date, test: __method__, method: :date_start_full)
    end
    
    def test_warnings
      test_runner(type: :result, test: __method__, method: :warnings)
    end

    def test_processing
      @tests_run << __method__
      if @processable
        test_for_processing_errors_handled
      else
        @test_results << :fail
        @messages << "Processing raises error: #{@errors.join(';')}"
      end
    end

    def test_for_processing_errors_handled
      errs = @result.errors
      if errs.empty?
        @test_results << :pass
        return
      end

      @messages << errs.join('; ')
      @test_results << :fail
    end
  end
end
