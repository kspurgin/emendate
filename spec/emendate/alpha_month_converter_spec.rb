# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::AlphaMonthConverter do
  def convert(str, options = {})
    pm = Emendate.prep_for(str, :convert_months, options)
    fs = Emendate::AlphaMonthConverter.new(tokens: pm.tokens)
    fs.convert.segments
  end

  describe '#convert' do
    context 'with month abbreviation' do
      it 'tags as expected' do
        c = convert('Jan 2021')
        result = "#{c.first.type} #{c.first.lexeme}"
        expect(result).to eq('month jan')
        expect(c.first.location.col).to eq(0)
        expect(c.first.location.length).to eq(4)
      end
    end

    context 'with month full' do
      it 'tags as expected' do
        c = convert('October 2021')
        result = "#{c.first.type} #{c.first.lexeme}"
        expect(result).to eq('month october')
      end
    end
  end
end
