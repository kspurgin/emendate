require 'spec_helper'

RSpec.describe Emendate::ParsedDate do
  before(:all){ @res = Emendate.parse('2/23/2021').dates.first }
  describe '#to_h' do
    it 'returns hash' do
      expected = {:original_string=>nil,
                  :index_dates=>[],
                  :date_start=>nil,
                  :date_end=>nil,
                  :date_start_full=>"2021-02-23",
                  :date_end_full=>"2021-02-23",
                  :inclusive_range=>nil,
                  :certainty=>[]}
      expect(@res.to_h).to eq(expected)
    end
  end

  describe '#to_json' do
    it 'returns JSON escaped string' do
      expected = <<~LONGSTRING
      {\"original_string\":null,\"index_dates\":[],\"date_start\":null,\"date_end\":null,\"date_start_full\":\"2021-02-23\",\"date_end_full\":\"2021-02-23\",\"inclusive_range\":null,\"certainty\":[]}
      LONGSTRING
      expect(@res.to_json).to eq(expected.chomp)
    end
  end

  describe '#valid_range?' do
    context 'not a range' do
      it 'returns true' do
        expect(@res.valid_range?).to be true
      end
    end

    context 'valid range' do
      it 'returns true' do
        d = Emendate.parse('mid 1800s to 2/23/21',
                           ambiguous_year_rollback_threshold: 0, 
                           pluralized_date_interpretation: :broad).dates.first
        expect(d.valid_range?).to be true
      end
    end

    context 'invalid range' do
      it 'returns false' do
        d = Emendate.parse('mid 1900s to 2/23/21',
                           ambiguous_year_rollback_threshold: 0, 
                           pluralized_date_interpretation: :broad).dates.first
        expect(d.valid_range?).to be false
      end
    end
  end
end
