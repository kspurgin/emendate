require 'spec_helper'

RSpec.describe Emendate::MonthSeasonYearAnalyzer do
  def prep(str, options = {})
    pm = Emendate.prep_for(str, :tag_date_parts, options)
    t = pm.standardized_formats
    r = Emendate::MonthSeasonYearAnalyzer.new(t[2], t[0], pm.options).result
    "#{r.type} #{r.lexeme}"
  end
  
  context 'unambiguous year-number - second less than first' do
    context 'second is month - 2020-03' do
      it 'returns month' do
        expect(prep('2020-03')).to eq('month 03')
      end
    end
    context 'second is season - 1995-28' do
      it 'returns season' do
        expect(prep('1995-28')).to eq('season 28')
      end
    end
  end

  context 'unambiguous year-number - second greater than first and cannot be month or season - 1995-99' do
    it 'returns year' do
      expect(prep('1995-99')).to eq('year 1999')
    end
  end

  context 'ambiguous year-number' do
    context 'second is possibly month - 2010-12' do
      context 'default behavior' do
        it 'returns year' do
          expect(prep('2010-12')).to eq('year 2012')
        end
      end
      context 'alternate behavior' do
        it 'returns month' do
          expect(prep('2010-12', ambiguous_month_year: :as_month)).to eq('month 12')
        end
      end
    end

    context 'second is possibly season - 2020-21' do
      context 'default behavior' do
        it 'returns year' do
          expect(prep('2020-21')).to eq('year 2021')
        end
      end
      context 'alternate behavior' do
        it 'returns season' do
          expect(prep('2020-21', ambiguous_month_year: :as_month)).to eq('season 21')
        end
      end
    end
  end
end

