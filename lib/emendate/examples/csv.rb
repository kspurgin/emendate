# frozen_string_literal: true

require "csv"
require_relative "row"

module Emendate
  module Examples
    # Parses examples CSV and converts each row of that table to an Examples::Row
    class Csv
      class << self
        # even more convenient access to specific rows for testing
        def rows(str, opt)
          new.retrieve_rows(str, opt)
        end
      end

      attr_reader :rows
      def initialize
        @rows = CSV.parse(File.read(Emendate.examples.file_path.call),
          headers: true)
          .map do |row|
          Row.new(row)
        end
      end

      # convenience method to extract specific row(s) by test fingerprint (test_string + test_options)
      #   for testing
      def retrieve_rows(str, opt)
        rows.select { |row| row.test_string == str }
          .select { |row| row.test_options == opt }
      end

      def to_s
        "#{rows.length} rows"
      end
      alias_method :inspect, :to_s
    end
  end
end
