require 'spec_helper'

RSpec.describe Emendate::AlphaMonthConverter do
  describe '#tag' do
    context 'month abbreviation' do
      it 'tags as expected' do
        l = Emendate::Lexer.new('Jan 2021')
        l.start_tokenization
        c = Emendate::AlphaMonthConverter.new(tokens: l.tokens)
        result = "#{c.convert.first.type} #{c.convert.first.lexeme}"
        expect(result).to eq('number_month 1')
      end
    end

    context 'month full' do
      it 'tags as expected' do
        l = Emendate::Lexer.new('October 2021')
        l.start_tokenization
        c = Emendate::AlphaMonthConverter.new(tokens: l.tokens)
        result = "#{c.convert.first.type} #{c.convert.first.lexeme}"
        expect(result).to eq('number_month 10')
      end
    end
  end
end
