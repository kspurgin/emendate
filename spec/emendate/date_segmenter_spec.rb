# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DateSegmenter do
  subject(:step){ described_class }

  after{ Emendate.reset_config }

  describe '.call' do
    let(:tokens){ prepped_for(string: str, target: step) }
    let(:result) do
      step.call(tokens)
          .value!
    end
    let(:types){ result.types }
    let(:certainty){ result.certainty }
    let(:warnings){ result.warnings }

    context 'with 1932-1942 or 1948-1949' do
      let(:str){ '1932-1942 or 1948-1949' }

      it 'segments as expected' do
        expect(types).to eq(
          %i[year_date_type range_indicator year_date_type
             date_separator
             year_date_type range_indicator year_date_type]
        )
        expect(certainty).to eq([:one_of_set])
        expect(warnings.length).to eq(0)
      end
    end

    context 'with circa 202127' do
      let(:str){ 'circa 202127' }

      it 'segments as expected' do
        expect(types).to eq(%i[year_date_type])
        expect(certainty).to eq([:approximate])
        expect(warnings.length).to eq(1)
        expect(result[0].literal).to eq(202_127)
      end
    end

    context 'with circa 202002' do
      let(:str){ 'circa 202002' }

      it 'segments as expected' do
        expect(types).to eq(%i[yearmonth_date_type])
        expect(certainty).to eq([:approximate])
        expect(result[0].year).to eq(2020)
        expect(result[0].month).to eq(2)
      end
    end

    context 'with 2002, summer' do
      let(:str){ '2002, summer' }

      it 'segments as expected' do
        expect(types).to eq(%i[yearseason_date_type])
        expect(certainty).to eq([])
        expect(result[0].year).to eq(2002)
        expect(result[0].month).to eq(22)
      end
    end

    context 'with autumn 2019-2020' do
      let(:str){ 'autumn 2019-2020' }

      it 'segments as expected' do
        expect(types).to eq(%i[yearseason_date_type range_indicator
                               year_date_type])
      end
    end

    context 'with Winter 2019-2020' do
      let(:str){ 'Winter 2019-2020' }

      it 'segments as expected' do
        expect(types).to eq(%i[yearseason_date_type])
      end
    end

    context 'with Winter 2019-2023' do
      let(:str){ 'Winter 2019-2023' }

      it 'segments as expected' do
        expect(types).to eq(%i[yearseason_date_type range_indicator
                               year_date_type])
      end
    end

    context 'with 20200229' do
      let(:str){ '20200229' }

      it 'returns ymd' do
        expect(types).to eq(%i[yearmonthday_date_type])
        expect(result[0].year).to eq(2020)
        expect(result[0].month).to eq(2)
        expect(result[0].day).to eq(29)
      end
    end

    context 'with 10000007' do
      let(:str){ '10000007' }

      it 'segments as expected' do
        expect(types).to eq(%i[year_date_type])
        expect(result.warnings).to include('10000007 treated as a long year')
        expect(result[0].literal).to eq(10_000_007)
      end
    end

    context 'with 20200229-20200304' do
      let(:str){ '20200229-20200304' }

      it 'segments as expected' do
        e = %i[yearmonthday_date_type range_indicator yearmonthday_date_type]
        expect(types).to eq(e)
      end
    end

    context 'with after 1815' do
      let(:str){ 'after 1815' }

      it 'segments as expected' do
        expect(types).to eq(%i[year_date_type])
        expect(result[0].range_switch).to eq(:after)
      end
    end

    context 'with early 19th c.' do
      let(:str){ 'early 19th c.' }

      it 'segments as expected' do
        expect(types).to eq(%i[century_date_type])
        expect(result[0].partial_indicator).to eq(:early)
      end
    end

    context 'with mid-19th century' do
      let(:str){ 'mid-19th century' }

      it 'segments as expected' do
        expect(types).to eq(%i[century_date_type])
        expect(result[0].partial_indicator).to eq(:mid)
      end
    end

    context 'with before early 19th c.' do
      let(:str){ 'before early 19th c.' }

      it 'segments as expected' do
        expect(types).to eq(%i[century_date_type])
        expect(result[0].partial_indicator).to eq(:early)
        expect(result[0].range_switch).to eq(:before)
      end
    end

    context 'with 1950s early' do
      let(:str){ '1950s early' }

      it 'segments as expected' do
        expect(types).to eq(%i[decade_date_type])
        expect(result[0].partial_indicator).to eq(:early)
      end
    end

    context 'with 17th or 18th century' do
      let(:str){ '17th or 18th century' }

      it 'segments as expected' do
        e = %i[century_date_type date_separator century_date_type]
        expect(types).to eq(e)
      end
    end

    context 'with late 19th to early 20th century' do
      let(:str){ 'late 19th to early 20th century' }

      it 'segments as expected' do
        expect(types).to eq(%i[century_date_type range_indicator century_date_type])
        expect(result[0].partial_indicator).to eq(:late)
        expect(result[2].partial_indicator).to eq(:early)
      end
    end

    context 'with 2-15-20' do
      let(:str){ '2-15-20' }

      it 'returns yearmonthday_date_type' do
        expect(types).to eq(%i[yearmonthday_date_type])
      end
    end

    context 'with 1974-present' do
      let(:str){ '1974-present' }

      it 'returns ...' do
        expect(types).to eq(
          %i[year_date_type range_indicator yearmonthday_date_type]
        )
      end
    end

    context 'with 231 BCE' do
      let(:str){ '231 BCE' }

      it 'returns ...' do
        expect(types).to eq(%i[year_date_type])
        expect(result[0].era).to eq(:bce)
      end
    end

    context 'with Spring 20' do
      before do
        Emendate.config.options.two_digit_year_handling = :coerce
        Emendate.config.options.ambiguous_year_rollback_threshold = 50
      end

      let(:str){ 'Spring 20' }

      it 'returns ...' do
        expect(types).to eq(%i[yearseason_date_type])
      end
    end

    # context 'with 2 December 2020, 2020/02/15' do
    #   it 'returns yearmonthday_date_type comma yearmonthday_datetype' do
    #     s = segment('2 December 2020, 2020/02/15')
    #     e = %i[yearmonthday_date_type comma yearmonthday_date_type]
    #     expect(s.types).to eq(e)
    #   end
    # end

    # context 'with Mar 20' do
    #   it 'returns yearmonth_date_type' do
    #     s = segment('Mar 20')
    #     e = %i[yearmonth_date_type]
    #     expect(s.types).to eq(e)
    #   end
    # end

    # context 'with 1990s 199X' do
    #   before(:all){ @s = segment('1990s 199X') }

    #   it 'returns decade_date_types' do
    #     e = %i[decade_date_type decade_date_type]
    #     expect(@s.types).to eq(e)
    #   end

    #   it 'returns decade_types: plural, uncertainty_digits' do
    #     e = 'plural uncertainty_digits'
    #     expect(@s.map(&:decade_type).join(' ')).to eq(e)
    #   end
    # end

    # context 'with 1900s (as century), 19th century, 19uu' do
    #   before(:all) do
    #     @s = segment('1900s 19th century 19uu', pluralized_date_interpretation: :broad)
    #   end

    #   it 'returns century_date_types' do
    #     e = %i[century_date_type century_date_type century_date_type]
    #     expect(@s.types).to eq(e)
    #   end

    #   it 'returns century_types: plural, name, uncertainty_digits' do
    #     e = 'plural name uncertainty_digits'
    #     expect(@s.map(&:century_type).join(' ')).to eq(e)
    #   end

    #   it 'returns century literals: 19 19 19' do
    #     expect(@s.map(&:literal).join(' ')).to eq('19 19 19')
    #   end
    # end

    # context 'with 1972 - 1999' do
    #   before(:all){ @s = segment('1972 - 1999') }

    #   it 'returns: year_date_type range_indicator year_date_type' do
    #     expect(@s.type_string).to eq('year_date_type range_indicator year_date_type')
    #   end
    # end
  end
end
