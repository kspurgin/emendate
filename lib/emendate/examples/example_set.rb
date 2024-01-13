# frozen_string_literal: true

require_relative "taggable"
require_relative "row_set"
require_relative "testable_example"

module Emendate
  module Examples
    # rubocop:todo Layout/LineLength
    # Basically just a holder for a list of Examples::TestableExample objects, with some convenience
    # rubocop:enable Layout/LineLength
    #   methods
    class ExampleSet
      include Examples::Taggable

      attr_reader :examples

      def initialize(data_sets: "", date_types: "", rows: nil)
        @rows = rows || Examples::RowSet.new(data_sets: data_sets,
          date_types: date_types)
          .rows
          .sort_by do |row|
          row.dateval_occurrence
        end

        set_up_tags(data_sets, date_types)

        @examples = @rows.group_by { |row| row.test_fingerprint }
          .values
          .map { |rows| Examples::TestableExample.new(rows) }
      end

      def all_tags
        examples.map(&:all_tags).flatten.uniq.sort
      end

      def by_type_pattern(date_only: false, stage: :tokens)
        examples.group_by do |example|
          example.type_pattern(date_only: date_only, stage: stage)
        end
          .sort_by { |pattern, data| pattern }
      end

      def failures
        grouped_by_test_status[:failure]
      end

      # rubocop:todo Layout/LineLength
      # @param examples_method [Symbol] name of method that returns Array of TestableExample objects
      # rubocop:enable Layout/LineLength
      # rubocop:todo Layout/LineLength
      # @param data_method [Symbol] name of method to call on each TestableExample to get data
      # rubocop:enable Layout/LineLength
      def get_example_data(data_method:, examples_method: :examples)
        exobjs = send(examples_method)
        return [] if exobjs.empty?

        exobjs.map(&data_method).uniq.sort
      end

      def not_run
        grouped_by_test_status[:no_tests_run]
      end

      def report_failures
        return unless failures
        return if failures.empty?

        puts "\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
        puts "FAILURES"
        puts "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
        failures.each { |failure| failure.report_failure }
        ""
      end

      # @param type [:successes, :not_run]
      def report_fingerprint(type)
        array = send(type)
        return if array.blank?

        puts "\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
        puts type.to_s.upcase
        puts "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
        puts get_example_data(examples_method: type, data_method: :fingerprint)
        ""
      end

      def report_type_patterns(date_only: false, stage: :tokens)
        by_type_pattern(date_only: date_only,
          stage: stage).each do |pattern, exset|
          puts pattern.inspect
          exset.each { |ex| puts "  #{ex.fingerprint}" }
        end

        puts "\n#{failures.length} examples could not be parsed" if failures
      end

      def summary
        puts "\n-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
        puts "SUMMARY"
        puts "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"

        str = %i[successes failures not_run].map { |meth| [meth, send(meth)] }
          .to_h
          .compact
          .map { |meth, vals| "#{vals.length} #{meth}" }
          .join(" -- ")
        puts str
      end

      def run_tests(tests: nil, fail_fast: false, mode: :normal)
        to_run = tests ? tests.intersection(runnable_tests) : runnable_tests
        examples.each do |example|
          example.run_tests(tests: to_run, fail_fast: fail_fast, mode: mode)
        end
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

      # @param type ['data_set', 'date_type']
      def tags(type)
        examples.map { |example| example.tags(type) }.flatten.uniq.sort
      end

      def type_patterns(date_only: false, stage: :tokens)
        by_type_pattern(date_only: date_only, stage: stage).keys.each do |key|
          puts key.inspect
        end
        ""
      end

      def to_s
        # rubocop:todo Layout/LineLength
        "#{self.class.name}: #{examples.length} examples from #{rows.length} rows #{tags_to_s}"
        # rubocop:enable Layout/LineLength
      end
      alias_method :inspect, :to_s

      private

      attr_reader :rows

      def determine_runnable_tests
        examples.map(&:runnable_tests).flatten.sort.uniq
      end

      def grouped_by_test_status
        examples.group_by { |example| example.test_status }
      end
    end
  end
end
