# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Emendate::DateTypes::YearMonth do
  context 'when created with month and year' do
    before(:all) do
      @dt = described_class.new(year: '2020', month: 2)
    end

    it 'type = :yearmonth_date_type' do
      expect(@dt.type).to eq(:yearmonth_date_type)
    end

    describe '#earliest' do
      it 'returns 2020-02-01' do
        expect(@dt.earliest).to eq(Date.new(2020, 2, 1))
      end
    end

    describe '#latest' do
      it 'returns 2020-02-29' do
        expect(@dt.latest).to eq(Date.new(2020, 2, 29))
      end
    end

    describe '#lexeme' do
      it 'returns 2020-02' do
        expect(@dt.lexeme).to eq('2020-02')
      end
    end

    describe '#literal' do
      it 'returns 2020-02' do
        expect(@dt.literal).to eq(202002)
      end
    end

    describe '#year' do
      it 'returns 2020' do
        expect(@dt.year).to eq(2020)
      end
    end

    describe '#month' do
      it 'returns 2' do
        expect(@dt.month).to eq(2)
      end
    end
  end

  context 'when created with literal' do
    before(:all) do
      @dt = described_class.new(literal: 202002)
    end

    it 'type = :yearmonth_date_type' do
      expect(@dt.type).to eq(:yearmonth_date_type)
    end

    describe '#earliest' do
      it 'returns 2020-02-01' do
        expect(@dt.earliest).to eq(Date.new(2020, 2, 1))
      end
    end

    describe '#latest' do
      it 'returns 2020-02-29' do
        expect(@dt.latest).to eq(Date.new(2020, 2, 29))
      end
    end

    describe '#lexeme' do
      it 'returns 2020-02' do
        expect(@dt.lexeme).to eq('2020-02')
      end
    end

    describe '#literal' do
      it 'returns 2020-02' do
        expect(@dt.literal).to eq(202002)
      end
    end

    describe '#year' do
      it 'returns 2020' do
        expect(@dt.year).to eq(2020)
      end
    end

    describe '#month' do
      it 'returns 2' do
        expect(@dt.month).to eq(2)
      end
    end
  end
end
