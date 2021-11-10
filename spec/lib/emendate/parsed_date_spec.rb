# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::ParsedDate do
  before(:all){ @res = Emendate.parse('2/23/2021').dates.first }

  describe '#to_h' do
    it 'returns hash' do
      expected = { original_string: '2/23/2021',
                   index_dates: [],
                   date_start: nil,
                   date_end: nil,
                   date_start_full: '2021-02-23',
                   date_end_full: '2021-02-23',
                   inclusive_range: nil,
                   certainty: [] }
      expect(@res.to_h).to eq(expected)
    end
  end

  describe '#to_json' do
    it 'returns JSON escaped string' do
      expected = <<~LONGSTRING
      {\"original_string\":\"2/23/2021\",\"index_dates\":[],\"date_start\":null,\"date_end\":null,\"date_start_full\":\"2021-02-23\",\"date_end_full\":\"2021-02-23\",\"inclusive_range\":null,\"certainty\":[]}
      LONGSTRING
      expect(@res.to_json).to eq(expected.chomp)
    end
  end

  describe '#valid_range?' do
    context 'when not a range' do
      it 'returns true' do
        expect(@res.valid_range?).to be true
      end
    end

    context 'when valid range' do
      context 'when both ends of range populated' do
        it 'returns true' do
          d = Emendate.parse('mid 1800s to 2/23/21',
                             ambiguous_year_rollback_threshold: 0,
                             pluralized_date_interpretation: :broad).dates.first
          expect(d.valid_range?).to be true
        end
      end

      context 'when only end of range populated (e.g. before 1920)' do
        it 'returns true' do
          d = Emendate.parse('before 1920').dates.first
          expect(d.valid_range?).to be true
        end
      end
    end

    context 'when invalid range' do
      it 'returns false' do
        dp = Emendate.parse('mid 1900s to 2/23/21',
                           ambiguous_year_rollback_threshold: 0,
                           pluralized_date_interpretation: :broad)
          d = dp.dates.first
        expect(d.valid_range?).to be false
      end
    end
  end
end
