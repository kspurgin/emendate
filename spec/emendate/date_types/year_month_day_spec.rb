# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DateTypes::YearMonthDay do
  let(:year){ '2020' }
  let(:month){ 2 }
  let(:day){ '29' }
  let(:dt){ Emendate::DateTypes::YearMonthDay.new(year: year, month: month, day: day) }
  
  it 'type = :yearmonthday_date_type' do
    expect(dt.type).to eq(:yearmonthday_date_type)
  end

  context '2020, 2, 29' do
    describe '#earliest' do
      it 'returns 2020-02-29' do
        expect(dt.earliest).to eq(Date.new(2020, 2, 29))
      end
    end

    describe '#latest' do
      it 'returns 2020-02-29' do
        expect(dt.latest).to eq(Date.new(2020, 2, 29))
      end
    end

    describe '#lexeme' do
      it 'returns 2020-02-29' do
        expect(dt.lexeme).to eq('2020-02-29')
      end
    end

    describe '#literal' do
      it 'returns 20200229' do
        expect(dt.literal).to eq(20200229)
      end
    end
  end

  context '600, 4, 21' do
    let(:year){ 600 }
    let(:month){ 4 }
    let(:day){ 21 }
    describe '#literal' do
      it 'returns 6000421' do
        expect(dt.literal).to eq(6000421)
      end
    end
  end
  
end
