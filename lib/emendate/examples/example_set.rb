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

    def runnable_tests
      examples.map(&:runnable_tests).flatten.sort.uniq
    end

    def to_s
      "#{examples.length} examples from #{rows.length} rows #{tags_to_s}"
    end
    alias_method :inspect, :to_s
    
    private

    attr_reader :rows
  end
end
