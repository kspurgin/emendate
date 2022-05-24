# frozen_string_literal: true

module Examples
  class Row
    attr_reader :row, :runnable_tests
    def initialize(row)
      @row = prep(row)
      # metaprogramming bit to create an instance variable for each column
      @row.keys.each{ |field| instance_variable_set("@#{field}".to_sym, row[field]) }
      @runnable_tests = determine_runnable_tests
    end

    def data_sets
      return [] if tags_data_set.blank?

      tags_data_set.split(';').sort
    end
    
    def date_types
      return [] if tags_date_type.blank?

      tags_date_type.split(';').sort
    end

    # type value must be: :data_sets or :date_types
    def tagged?(type:, tags:)
      all_tags = self.method(type).call
      return false if all_tags.empty?

      i = all_tags.intersection(tags)
      return true if i.length == tags.length

      false
    end

    def warnings
      return [] if result_warnings.blank?

      result_warnings.split(';')
    end
    
    def test_fingerprint
      "#{test_string}/#{test_options}"
    end

    private

    def determine_runnable_tests
      row.keys
        .select{ |field| test_expectation?(field) }
        .select{ |field| Examples::Test::IMPLEMENTED.any?(field) }
    end

    # metaprogramming bit to avoid manually declaring attr_reader for every column in row
    def method_missing(symbol, *args)
      instance_variable_get("@#{symbol}".to_sym)
    rescue
      super(symbol, *args)
    end

    def prep(row)
      r = row.to_h
      r = r.transform_values{ |val| val == 'nilValue' ? nil : val }
      r = r.transform_values{ |val| val == 'today' ? Date.today : val }
      r
    end

    def test_expectation?(field)
      %w[date result translation].any?(field.split('_').first)
    end
  end
end
