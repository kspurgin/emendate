require 'spec_helper'

RSpec.describe Emendate::DateSegmenter do

  def segment(str, options = {})
    pm = Emendate.prep_for(str, :segment_dates, options)
    ds = Emendate::DateSegmenter.new(tokens: pm.tokens, options: pm.options)
    ds.segment
  end
       
  describe '#segmentation' do
    context 'circa 202127' do
      before(:all){ @s = segment('circa 202127') }
      it 'returns year_date_type' do
        expect(@s.type_string).to eq('year_date_type')
      end
      it 'retains certainty' do
        expect(@s.certainty).to eq([:approximate])
      end
      it 'returns long year warning' do
        expect(@s.warnings.length).to eq(1)
      end
    end

    context 'circa 202002' do
      it 'returns expected' do
        s = segment('circa 202002')
        e = %i[yearmonth_date_type]
        expect(s.types).to eq(e)
      end
    end

    context '20200229' do
      it 'returns ymd' do
        s = segment('20200229')
        e = %i[yearmonthday_date_type]
        expect(s.types).to eq(e)
      end
    end

    context '10000007' do
      before(:all){ @s = segment('10000007') }
      it 'returns year' do
        expect(@s.type_string).to eq('year_date_type')
      end
      it 'includes a warning' do
        expect(@s.warnings).to include('10000007 treated as a long year')
      end
    end

    context '20200229-20200304' do
      it 'returns ymd' do
        s = segment('20200229-20200304')
        e = 'yearmonthday_date_type hyphen yearmonthday_date_type'
        expect(s.type_string).to eq(e)
      end
    end

    context 'early 19th c.' do
      it 'returns expected' do
        s = segment('early 19th c.')
        e = %i[partial century_date_type]
        expect(s.types).to eq(e)
      end
    end

    context '17th or 18th century' do
      xit 'returns expected' do
        s = segment('17th or 18th century')
        e = %i[century_date_type century_date_type]
        expect(s.types).to eq(e)
      end
    end

    context '2-15-20' do
      xit 'returns expected' do
        s = segment('2-15-20')
        e = %i[century_date_type century_date_type]
        expect(s.types).to eq(e)
      end
    end
  end
end
