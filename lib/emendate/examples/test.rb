# frozen_string_literal: true

module Examples
  # Handles combining rows with the same test_string/test_options into one set of testable data,
  #   determining what tests can be run on the data, and running the tests
  #
  # @todo Single responsibility principle!
  class Test
    IMPLEMENTED = %w[
                     date_start_full date_end_full
                     result_warnings
                     translation_lyrasis_pseudo_edtf
                    ]

    attr_reader :string, :pattern, :options, :result, :messages, :runnable_tests
    def initialize(rows)
      @rows = rows.sort_by!{ |row| row.occurrence }
      @string = rows.first.string
      @pattern = rows.first.pattern
      @options = rows.first.options
      @runnable_tests = determine_runnable_tests
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
      #{result_string}: #{string} {#{options}}
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

    attr_reader :rows

    def determine_runnable_tests
      runnables = rows.map(&:runnable_tests)
      return runnables.flatten if runnables.length == 1

      runnables.shift.intersection(*runnables)
    end

    def result_string
      success? ? 'PASS' : 'FAIL'
    end

    def all_tests
      # test_date_start test_date_end -- not implemented by application yet
      %i[
         test_date_start_full test_date_end_full
         test_warnings
         test_lyrasis_pseudo_edtf
        ]
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

    def translate_call
      "Emendate.translate('#{string}', #{options})"
    end

    def translate
      instance_eval(translate_call)
    end

    def get_result(type, method)
      case type
      when :date
        dates = result.result.dates
        return [nil] if dates.empty?
        
        dates.map{ |date| date.send(method) }
      when :result
        result.result.send(method)
      when :output
        translate.value
      end
    end

    def get_expected(type, method)
      case type
      when :date
        @rows.map{ |row| row.send(method) }
      when :result
        @rows.map{ |row| row.send(method) }.flatten.uniq
      when :output
        @rows.map{ |row| row.send(method) }.flatten.uniq[0]
      end
    end
    
    def test_runner(type:, test:, method:)
      @tests_run << test
      got = get_result(type, method)
      exp = get_expected(type, method)
      if got == exp
        @test_results << :pass
        return
      end

      @test_results << :fail
      @messages << "#{method}: EXPECTED: #{exp.join('|')}, GOT: #{got.join('|')}" unless type == :output
      @messages << "#{method}: EXPECTED: #{exp}, GOT: #{got}" if type == :output
    end

    def test_date_end
      test_runner(type: :date, test: __method__, method: :date_end)
    end

    def test_date_start
      test_runner(type: :date, test: __method__, method: :date_start)
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

    def output_options(dialect)
      return "target_dialect: :#{dialect}" if options.blank?
      
      "#{options}, target_dialect: :#{dialect}"
    end
    
    def test_lyrasis_pseudo_edtf
      dialect = :lyrasis_pseudo_edtf
      @options = "#{output_options(dialect)}, unknown_date_output: :custom, unknown_date_output_string: 'not dated'"
      test_runner(type: :output, test: __method__, method: dialect)
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
