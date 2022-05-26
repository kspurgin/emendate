# frozen_string_literal: true

require_relative 'taggable'

module Emendate
  module Examples
    # Optionally filters Csv rows by date type and/or data set tags. If those are not given,
    #   returns all Csv rows
    #
    # A Row is literally one row of data, which may or may not be a testable example set on
    #   its own. Examples::ExampleSet handles grouping rows into TestableExample objects
    class RowSet
      include Examples::Taggable

      attr_reader :rows
      
      def initialize(data_sets: '', date_types: '')
        @csvrows = Examples::Csv.new.rows
        set_up_tags(data_sets, date_types)
        @rows = filter_rows
      end

      def to_s
        "#{rows.length} rows #{tags_to_s}"
      end
      alias_method :inspect, :to_s

      private

      attr_reader :csvrows

      def filter_rows
        return csvrows if data_sets.empty? && date_types.empty?

        select_rows
      end

      def select_by_data_set
        return csvrows if data_sets.empty?

        csvrows.select{ |row| row.tagged?(type: :data_sets, tags: data_sets) }
      end

      def select_by_date_type(dataset_rows)
        return dataset_rows if date_types.empty?

        dataset_rows.select{ |row| row.tagged?(type: :date_types, tags: date_types) }
      end

      def select_rows
        dataset_rows = select_by_data_set
        return dataset_rows if dataset_rows.empty?

        select_by_date_type(dataset_rows)
      end
    end
  end
end
