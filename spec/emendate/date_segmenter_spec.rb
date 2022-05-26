# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DateSegmenter do

  def segment(str, options = {})
    pm = Emendate.prep_for(str, :segment_dates, options)
    ds = Emendate::DateSegmenter.new(tokens: pm.tokens, options: pm.options)
    ds.segment
  end

  describe '#segmentation' do
    context 'with circa 202127' do
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

      it 'creates datetype with expected literal' do
        expect(@s[0].literal).to eq(202127)
      end
    end

    context 'with circa 202002' do
      before(:all){ @s = segment('circa 202002') }

      it 'returns expected' do
        e = %i[yearmonth_date_type]
        expect(@s.types).to eq(e)
      end

      it 'retains certainty' do
        expect(@s.certainty).to eq([:approximate])
      end

      it 'creates datetype with expected year' do
        expect(@s[0].year).to eq(2020)
      end

      it 'creates datetype with expected month' do
        expect(@s[0].month).to eq(2)
      end
    end

    context 'with 20200229' do
      before(:all){ @s = segment('20200229') }

      it 'returns ymd' do
        e = 'yearmonthday_date_type'
        expect(@s.type_string).to eq(e)
      end

      it 'creates datetype with expected year' do
        expect(@s[0].year).to eq(2020)
      end

      it 'creates datetype with expected month' do
        expect(@s[0].month).to eq(2)
      end

      it 'creates datetype with expected day' do
        expect(@s[0].day).to eq(29)
      end
    end

    context 'with 10000007' do
      before(:all){ @s = segment('10000007') }

      it 'returns year' do
        expect(@s.type_string).to eq('year_date_type')
      end

      it 'includes a warning' do
        expect(@s.warnings).to include('10000007 treated as a long year')
      end

      it 'creates datetype with expected literal' do
        expect(@s[0].literal).to eq(10000007)
      end
    end

    context 'with 20200229-20200304' do
      it 'returns yearmonthday - yearmonthday' do
        s = segment('20200229-20200304')
        e = 'yearmonthday_date_type range_indicator yearmonthday_date_type'
        expect(s.type_string).to eq(e)
      end
    end

    context 'with after 1815' do
      before(:all){ @s = segment('after 1815') }

      it 'returns expected' do
        expect(@s.type_string).to eq('year_date_type')
      end
    end

    context 'with early 19th c.' do
      before(:all){ @s = segment('early 19th c.') }

      it 'returns century_date_type' do
        expect(@s.type_string).to eq('century_date_type')
      end

      it 'partial_indicator = early' do
        expect(@s[0].partial_indicator).to eq('early')
      end
    end

    context 'with before early 19th c.' do
      before(:all){ @s = segment('before early 19th c.') }

      it 'returns century_date_type' do
        expect(@s.type_string).to eq('century_date_type')
      end

      it 'partial_indicator = early' do
        expect(@s[0].partial_indicator).to eq('early')
      end

      it 'range_switch = before' do
        expect(@s[0].range_switch).to eq('before')
      end
    end

    context 'with 17th or 18th century' do
      it 'returns expected' do
        s = segment('17th or 18th century')
        e = %i[century_date_type century_date_type]
        expect(s.types).to eq(e)
      end
    end

    context 'with late 19th to early 20th century' do
      before(:all){ @s = segment('late 19th to early 20th century') }

      it 'returns expected' do
        expect(@s.type_string).to eq('century_date_type range_indicator century_date_type')
      end

      it 'applies partial_indicators' do
        e = "#{@s[0].partial_indicator} #{@s[2].partial_indicator}"
        expect(e).to eq('late early')
      end
    end

    context 'with 2-15-20' do
      it 'returns yearmonthday_date_type' do
        s = segment('2-15-20')
        e = %i[yearmonthday_date_type]
        expect(s.types).to eq(e)
      end
    end

    context 'with 2 December 2020, 2020/02/15' do
      it 'returns yearmonthday_date_type comma yearmonthday_datetype' do
        s = segment('2 December 2020, 2020/02/15')
        e = %i[yearmonthday_date_type comma yearmonthday_date_type]
        expect(s.types).to eq(e)
      end
    end

    context 'with Mar 20' do
      it 'returns yearmonth_date_type' do
        s = segment('Mar 20')
        e = %i[yearmonth_date_type]
        expect(s.types).to eq(e)
      end
    end

    context 'with 1990s 199X' do
      before(:all){ @s = segment('1990s 199X') }

      it 'returns decade_date_types' do
        e = %i[decade_date_type decade_date_type]
        expect(@s.types).to eq(e)
      end

      it 'returns decade_types: plural, uncertainty_digits' do
        e = 'plural uncertainty_digits'
        expect(@s.map(&:decade_type).join(' ')).to eq(e)
      end
    end

    context 'with 1900s (as century), 19th century, 19uu' do
      before(:all) do
        @s = segment('1900s 19th century 19uu', pluralized_date_interpretation: :broad)
      end

      it 'returns century_date_types' do
        e = %i[century_date_type century_date_type century_date_type]
        expect(@s.types).to eq(e)
      end

      it 'returns century_types: plural, name, uncertainty_digits' do
        e = 'plural name uncertainty_digits'
        expect(@s.map(&:century_type).join(' ')).to eq(e)
      end

      it 'returns century literals: 19 19 19' do
        expect(@s.map(&:literal).join(' ')).to eq('19 19 19')
      end
    end

    context 'with 1972 - 1999' do
      before(:all){ @s = segment('1972 - 1999') }

      it 'returns: year_date_type range_indicator year_date_type' do
        expect(@s.type_string).to eq('year_date_type range_indicator year_date_type')
      end
    end
  end
end
