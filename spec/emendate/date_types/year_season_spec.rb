# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DateTypes::YearSeason do
  let(:subject){ described_class.new(**opts) }

  context 'when created with month, year, and children' do
    let(:opts) do
      tokens = [
        Emendate::Token.new(
          type: :season,
          lexeme: 'summer',
          location: Emendate::Location.new(6, 6)
        ),
        Emendate::Token.new(
          type: :year,
          lexeme: '2002, ',
          location: Emendate::Location.new(0, 6)
        )
      ]
      { year: '2020', month: 22, sources: tokens }
    end

    describe '#type' do
      it 'type = :yearseason_date_type' do
        expect(subject.type).to eq(:yearseason_date_type)
      end
    end

    describe '#location' do
      it 'returns 0, 12' do
        expect(subject.location.col).to eq(0)
        expect(subject.location.length).to eq(12)
      end
    end

    describe '#earliest' do
      it 'returns 2020-07-01' do
        expect(subject.earliest).to eq(Date.new(2020, 7, 1))
      end
    end

    describe '#earliest_at_granularity' do
      it 'returns 2020-22' do
        expect(subject.earliest_at_granularity).to eq('2020-22')
      end
    end

    describe '#latest' do
      it 'returns 2020-09-30' do
        expect(subject.latest).to eq(Date.new(2020, 9, 30))
      end
    end

    describe '#latest_at_granularity' do
      it 'returns 2020-22' do
        expect(subject.latest_at_granularity).to eq('2020-22')
      end
    end

    describe '#lexeme' do
      it 'returns 2020-22' do
        expect(subject.lexeme).to eq('2020-22')
      end
    end

    describe '#literal' do
      it 'returns 202022' do
        expect(subject.literal).to eq(202_022)
      end
    end

    describe '#year' do
      it 'returns 2020' do
        expect(subject.year).to eq(2020)
      end
    end

    describe '#month' do
      it 'returns 22' do
        expect(subject.month).to eq(22)
      end
    end
  end

  context 'when created with literal' do
    let(:opts){ { literal: 202_022 } }

    it 'type = :yearseason_date_type' do
      expect(subject.type).to eq(:yearseason_date_type)
    end

    describe '#year' do
      it 'returns 2020' do
        expect(subject.year).to eq(2020)
      end
    end

    describe '#month' do
      it 'returns 22' do
        expect(subject.month).to eq(22)
      end
    end
  end
end
