require 'spec_helper'

RSpec.describe Emendate::AlphaMonthConverter do
  def convert(str, options = {})
    pm = Emendate.prep_for(str, :convert_months, options)
    fs = Emendate::AlphaMonthConverter.new(tokens: pm.tokens, options: pm.options)
    fs.convert.segments
  end

  describe '#tag' do
    context 'month abbreviation' do
      it 'tags as expected' do
        c = convert('Jan 2021')
        result = "#{c.first.type} #{c.first.lexeme}"
        expect(result).to eq('number_month jan')
      end
    end

    context 'month full' do
      it 'tags as expected' do
        c = convert('October 2021')
        result = "#{c.first.type} #{c.first.lexeme}"
        expect(result).to eq('number_month october')
      end
    end
  end
end
