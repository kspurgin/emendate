require 'spec_helper'

RSpec.describe Emendate::AlphaMonthConverter do
  describe '#tag' do
    context 'month abbreviation' do
      it 'tags as expected' do
        l = Emendate.lex('Jan 2021')
        c = Emendate::AlphaMonthConverter.new(tokens: l.tokens)
        result = "#{c.convert.first.type} #{c.convert.first.lexeme}"
        expect(result).to eq('number_month jan')
      end
    end

    context 'month full' do
      it 'tags as expected' do
        l = Emendate.lex('October 2021')
        c = Emendate::AlphaMonthConverter.new(tokens: l.tokens)
        result = "#{c.convert.first.type} #{c.convert.first.lexeme}"
        expect(result).to eq('number_month october')
      end
    end
  end
end
