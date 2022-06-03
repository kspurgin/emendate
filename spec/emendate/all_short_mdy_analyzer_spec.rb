# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::AllShortMdyAnalyzer do
  subject(:analyzer){ described_class.new(tokens) }
  
  let(:tokens){ Emendate.prep_for(str, :tag_date_parts).standardized_formats }

  describe '#call' do
    let(:result){ analyzer.call }
    let(:types){ result.types }
    let(:year){ result.when_type(:year)[0].literal }

    context 'with 87-04-13 (all unambiguous)' do
      let(:str){ '87-04-13' }
      
      it 'converts to date types' do
        expect(types).to eq(%i[year month day])
        expect(year).to eq(1987)
      end
    end

    context 'with 10-02-06 (all ambiguous)' do
      let(:str){ '10-02-06' }

      it 'converts to date types (default order)' do
        expect(types).to eq(%i[month day year])
        expect(year).to eq(2006)
      end

      context 'with day month year option' do
        before{ Emendate.options.ambiguous_month_day_year = :day_month_year }

        it 'converts to date types' do
          expect(types).to eq(%i[day month year])
          expect(year).to eq(2006)
        end
      end

      context 'with year month day option' do
        before{ Emendate.options.ambiguous_month_day_year = :year_month_day }

        it 'converts to date types' do
          expect(types).to eq(%i[year month day])
          expect(year).to eq(2010)
        end
      end

      context 'with year day month option' do
        before{ Emendate.options.ambiguous_month_day_year = :year_day_month }

        it 'converts to date types' do
          expect(types).to eq(%i[year day month])
          expect(year).to eq(2010)
        end
      end
    end

    context 'with 50-02-03 (ambiguous month/day)' do
      let(:str){ '50-02-03' }

      it 'returns day month year (with default options)' do
        expect(types).to eq(%i[year month day])
        expect(year).to eq(1950)
      end

    end

    context 'with 90-31-29 (invalid)' do
      let(:str){ '90-31-29' }

      it 'raises error' do
        expect{ types }.to raise_error(Emendate::AllShortMdyAnalyzer::MonthDayYearError)
      end
    end
  end
end

