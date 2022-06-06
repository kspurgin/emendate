# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::ParsedDate do
  subject(:parsed){ described_class.new(*args) }

  let(:pos){ 0 }
  let(:args) do
    pm = Emendate.process(str, options)
    dateparts = pm.tokens.segments.select{ |t| t.date_type? }
    [dateparts[pos], pm.tokens.certainty, pm.orig_string]
  end

  let(:options){ {} }

  
  describe '#to_h' do
    let(:result){ parsed.to_h }
    context 'with 2/23/2021' do
      let(:str){ '2/23/2021' }

      let(:expected) do
        { original_string: '2/23/2021',
         index_dates: [],
         date_start: nil,
         date_end: nil,
         date_start_full: '2021-02-23',
         date_end_full: '2021-02-23',
         inclusive_range: nil,
         certainty: [] }
      end
      
      it 'returns as expected' do
        expect(result).to eq(expected)
      end
    end
  end

  describe '#to_json' do
    let(:result){ parsed.to_json }
    context 'with 2/23/2021' do
      let(:str){ '2/23/2021' }

      it 'returns as expected' do
        expected = <<~LONGSTRING
      {\"original_string\":\"2/23/2021\",\"index_dates\":[],\"date_start\":null,\"date_end\":null,\"date_start_full\":\"2021-02-23\",\"date_end_full\":\"2021-02-23\",\"inclusive_range\":null,\"certainty\":[]}
      LONGSTRING
        expect(result).to eq(expected.chomp)
      end
    end
  end

  describe '#original_string' do
    let(:result){ parsed.original_string }
    
    context 'with 2/23/2021' do
      let(:str){ '2/23/2021' }

      it 'returns as expected' do
        expect(result).to eq(str)
      end
    end

    context 'with n.d.' do
      let(:str){ 'n.d.' }

      it 'returns as expected' do
        expect(result).to eq(str)
      end
    end
  end

  describe '#valid_range?' do
    let(:options) do
      {ambiguous_year_rollback_threshold: 0,
       pluralized_date_interpretation: :broad }
    end
    let(:result){ parsed.valid_range? }

    context 'when not a range' do
      let(:str){ '2/23/2021' }
      
      it 'returns true' do
        expect(result).to be true
      end
    end

    context 'when valid range' do
      context 'when both ends of range populated' do
        let(:str){ 'mid 1800s to 2/23/21' }
        
        it 'returns true' do
          expect(result).to be true
        end
      end

      context 'when only end of range populated (e.g. before 1920)' do
        let(:str){ 'before 1920' }
        it 'returns true' do
          expect(result).to be true
        end
      end
    end

    context 'when invalid range' do
      let(:str){ 'mid 1900s to 2/23/21' }
      
      it 'returns false' do
        expect(result).to be false
      end
    end
  end
end
