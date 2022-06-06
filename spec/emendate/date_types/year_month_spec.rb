# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DateTypes::YearMonth do
  let(:subject){ described_class.new(**opts) }
  
  context 'when created with month and year' do
    let(:opts){ {year: '2020', month: 2} }
    
    it 'type = :yearmonth_date_type' do
      expect(subject.type).to eq(:yearmonth_date_type)
    end

    describe '#earliest' do
      it 'returns 2020-02-01' do
        expect(subject.earliest).to eq(Date.new(2020, 2, 1))
      end
    end

    describe '#latest' do
      it 'returns 2020-02-29' do
        expect(subject.latest).to eq(Date.new(2020, 2, 29))
      end
    end

    describe '#lexeme' do
      it 'returns 2020-02' do
        expect(subject.lexeme).to eq('2020-02')
      end
    end

    describe '#literal' do
      it 'returns 2020-02' do
        expect(subject.literal).to eq(202002)
      end
    end

    describe '#year' do
      it 'returns 2020' do
        expect(subject.year).to eq(2020)
      end
    end

    describe '#month' do
      it 'returns 2' do
        expect(subject.month).to eq(2)
      end
    end
  end

  context 'when created with literal' do
    let(:opts){ {literal: 202002} }

    it 'type = :yearmonth_date_type' do
      expect(subject.type).to eq(:yearmonth_date_type)
    end

    describe '#earliest' do
      it 'returns 2020-02-01' do
        expect(subject.earliest).to eq(Date.new(2020, 2, 1))
      end
    end

    describe '#latest' do
      it 'returns 2020-02-29' do
        expect(subject.latest).to eq(Date.new(2020, 2, 29))
      end
    end

    describe '#lexeme' do
      it 'returns 2020-02' do
        expect(subject.lexeme).to eq('2020-02')
      end
    end

    describe '#literal' do
      it 'returns 2020-02' do
        expect(subject.literal).to eq(202002)
      end
    end

    describe '#year' do
      it 'returns 2020' do
        expect(subject.year).to eq(2020)
      end
    end

    describe '#month' do
      it 'returns 2' do
        expect(subject.month).to eq(2)
      end
    end
  end
end
