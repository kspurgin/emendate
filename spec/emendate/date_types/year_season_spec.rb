# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DateTypes::YearSeason do
  let(:subject){ described_class.new(**opts) }

  context 'when created with month, year, and sources' do
    let(:opts) do
      segmentset = prepped_for(
        string: 'summer 2020', target: Emendate::DateSegmenter
      )
      { year: '2020', month: 22, sources: segmentset.segments }
    end

    it 'creates datetype as expected' do
      expect(subject.type).to eq(:yearseason_date_type)
      expect(subject.location.col).to eq(0)
      expect(subject.location.length).to eq(11)
      expect(subject.earliest).to eq(Date.new(2020, 7, 1))
      expect(subject.earliest_at_granularity).to eq('2020-07')
      expect(subject.latest).to eq(Date.new(2020, 9, 30))
      expect(subject.latest_at_granularity).to eq('2020-09')
      expect(subject.lexeme).to eq('summer 2020')
      expect(subject.year).to eq(2020)
      expect(subject.literal).to eq(202022)
      expect(subject.month).to eq(22)
    end
  end

  context 'with :include_prev_year' do
    let(:opts) do
      segmentset = prepped_for(
        string: 'Winter 2019-2020', target: Emendate::DateSegmenter
      )
      { year: '2020', month: 24, sources: segmentset.segments,
        include_prev_year: true }
    end

    it 'creates datetype as expected' do
      expect(subject.type).to eq(:yearseason_date_type)
      expect(subject.location.col).to eq(0)
      expect(subject.location.length).to eq(16)
      expect(subject.earliest).to eq(Date.new(2019, 12, 1))
      expect(subject.earliest_at_granularity).to eq('2019-12')
      expect(subject.latest).to eq(Date.new(2020, 3, 31))
      expect(subject.latest_at_granularity).to eq('2020-03')
      expect(subject.lexeme).to eq('Winter 2019-2020')
      expect(subject.year).to eq(2020)
      expect(subject.literal).to eq(202024)
      expect(subject.month).to eq(24)
    end
  end

  context 'when created with literal' do
    let(:opts){ { literal: 202022 } }

    it 'creates datetype as expected' do
      expect(subject.type).to eq(:yearseason_date_type)
      expect(subject.lexeme).to eq('202022')
      expect(subject.year).to eq(2020)
      expect(subject.month).to eq(22)
    end
  end
end
