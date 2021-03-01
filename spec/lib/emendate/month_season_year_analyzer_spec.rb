require 'spec_helper'

RSpec.describe Emendate::MonthSeasonYearAnalyzer do
  def prep(str, options = {})
    pm = Emendate.prep_for(str, :tag_date_parts, options)
    t = pm.standardized_formats
    r = Emendate::MonthSeasonYearAnalyzer.new(t[2], t[0], pm.options)
    "#{r.result.type} #{r.result.lexeme} #{r.ambiguous}"
  end
  
  context 'with unambiguous year-number - second less than first' do
    context 'with month as second element - 2020-03' do
      it 'returns month' do
        expect(prep('2020-03')).to eq('month 03 false')
      end
    end
    context 'with season as second element - 1995-28' do
      it 'returns season' do
        expect(prep('1995-28')).to eq('season 28 false')
      end
    end
  end

  context 'with unambiguous year-number - second greater than first and cannot be month or season - 1995-99' do
    it 'returns year' do
      expect(prep('1995-99')).to eq('year 1999 false')
    end
  end

  context 'with ambiguous year-number' do
    context 'with second element possibly a month - 2010-12' do
      context 'when default option' do
        it 'returns year' do
          expect(prep('2010-12')).to eq('year 2012 true')
        end
      end
      context 'when ambiguous_month_year: :as_month' do
        it 'returns month' do
          expect(prep('2010-12', ambiguous_month_year: :as_month)).to eq('month 12 true')
        end
      end
    end

    context 'with second element possibly a season - 2020-21' do
      context 'when default option' do
        it 'returns year' do
          expect(prep('2020-21')).to eq('year 2021 true')
        end
      end
      context 'when ambiguous_month_year: :as_month' do
        it 'returns season' do
          expect(prep('2020-21', ambiguous_month_year: :as_month)).to eq('season 21 true')
        end
      end
    end
  end
end

