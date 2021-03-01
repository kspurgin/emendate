require 'spec_helper'

RSpec.describe Emendate::MonthDayAnalyzer do
  def prep(str, opt = :as_month_day)
    pm = Emendate.prep_for(str, :tag_date_parts)
    t = pm.standardized_formats
    mda = Emendate::MonthDayAnalyzer.new(t[0], t[2], t[4], opt)
    mda.month.nil? ? 'ambiguous' : "#{mda.month.lexeme} #{mda.day.lexeme}"
  end
  
  context 'with unambiguous month day - 12-31-2020' do
    it 'returns expected' do
      expect(prep('12-31-2001')).to eq('12 31')
    end
  end

  context 'with unambiguous day month - 31-12-2020' do
    it 'returns expected' do
      expect(prep('31-12-2001')).to eq('12 31')
    end
  end

  context 'with ambiguous - 02-03-2020' do
    context 'when default option (month day)' do
      it 'Feb 3' do
        expect(prep('02-03-2020')).to eq('02 03')
      end
    end

    context 'when as_day_month' do
      it 'Feb 3' do
        expect(prep('02-03-2020', :as_day_month)).to eq('03 02')
      end
    end

    context 'with invalid - 31-29-2020' do
      it 'raises error' do
        expect{ prep('31-29-2001') }.to raise_error(Emendate::MonthDayAnalyzer::MonthDayError)
      end
    end
  end
end
