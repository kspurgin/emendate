# frozen_string_literal: true

module Examples
  class Row
    attr_reader :row, :string, :pattern, :options, :occurrence, :date_start_full, :date_end_full
    def initialize(row)
      @row = prep(row)
      @string = @row['examplestring']
      @pattern = @row['examplepattern']
      @options = @row['options']
      @occurrence = @row['occurrence']
      @date_start_full = @row['start_full']
      @date_end_full = @row['end_full']
    end

    def data_sets
      data = row['tags_data_set']
      return [] if data.blank?

      data.split(';').sort
    end
    
    def date_types
      data = row['tags_date_type']
      return [] if data.blank?

      data.split(';').sort
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
      warns = @row['warnings']
      return [] if warns.blank?

      warns.split(';')
    end
    
    
    def test_fingerprint
      "#{string}/#{options}"
    end

    private
    

    def prep(row)
      r = row.to_h
      r = r.transform_values{ |val| val == 'nilValue' ? nil : val }
      r = r.transform_values{ |val| val == 'today' ? Date.today : val }
      r
    end
  end
end
