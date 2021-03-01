require 'spec_helper'

RSpec.describe Emendate::Result do
  context 'with invalid range' do
    it 'returns relevant warning' do
      res = Emendate.parse('mid 1900s to 2/23/21', ambiguous_year_rollback_threshold: 0, 
pluralized_date_interpretation: :broad)
      w = 'Date #1 is not a valid date range'
      expect(res.warnings).to include(w)
    end
  end

  describe '#to_h' do
    it 'returns hash' do
      res = Emendate.parse('mid 1800s to 2/23/21').to_h
      expected = {:original_string=>"mid 1800s to 2/23/21",
                  :dates=>
                  [{:original_string=>nil,
                    :index_dates=>[],
                    :date_start=>nil,
                    :date_end=>nil,
                    :date_start_full=>"1804-01-01",
                    :date_end_full=>"1921-02-23",
                    :inclusive_range=>true,
                    :certainty=>[]}],
                  :errors=>[],
                  :warnings=>["Interpreting pluralized year as decade"]}
      expect(res).to eq(expected)
    end
  end

  describe '#to_json' do
    it 'returns JSON escaped string' do
      res = Emendate.parse('mid 1800s to 2/23/21').to_json
      expected = <<~LONGSTRING
      {\"original_string\":\"mid 1800s to 2/23/21\",\"dates\":[{\"original_string\":null,\"index_dates\":[],\"date_start\":null,\"date_end\":null,\"date_start_full\":\"1804-01-01\",\"date_end_full\":\"1921-02-23\",\"inclusive_range\":true,\"certainty\":[]}],\"errors\":[],\"warnings\":[\"Interpreting pluralized year as decade\"]}
      LONGSTRING
      expect(res).to eq(expected.chomp)
    end
  end
end
