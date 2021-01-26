require 'spec_helper'

RSpec.describe Emendate::DateSegmenter do
  def segment(str, options = {})
    l = Emendate.lex(str)
    c = Emendate::AlphaMonthConverter.new(tokens: l.tokens)
    t = Emendate::OrdinalTranslator.new(tokens: c.convert)
    s = Emendate::DateSegmenter.new(tokens: t.translate)
    s.segment
  end
  
  describe '#segmentation' do
    context 'circa 202127' do
      it 'returns expected' do
        s = segment('circa 202127')
        e = %i[approximate number6]
        expect(s.types).to eq(e)
      end
    end

    context 'circa 202002' do
      it 'returns expected' do
        s = segment('circa 202002')
        e = %i[approximate yearmonth_date_type]
        expect(s.types).to eq(e)
      end
    end

    context '20200229' do
      it 'returns expected' do
        s = segment('20200229')
        e = %i[yearmonthday_date_type]
        expect(s.types).to eq(e)
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
      it 'returns expected' do
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
