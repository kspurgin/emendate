# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DateTypes::Century do
  subject(:century){ described_class.new(**args) }

  context 'when called without century_type' do
    let(:args){ {literal: 19} }

    it 'raises error' do
      expect{ subject }.to raise_error(Emendate::MissingCenturyTypeError)
    end
  end

  context 'when called with unsupported century_type value' do
    let(:args) { {} }

    it 'raises error' do
      err = Emendate::CenturyTypeValueError
      expect{described_class.new(literal: 19, century_type: :misc) }.to raise_error(err)
    end
  end

  context 'with textual century name (19th)' do
    let(:args) { {literal: 19, century_type: :name} }

    it 'returns expected values' do
      expect(subject.type).to eq(:century_date_type)
      expect(subject.earliest).to eq(Date.new(1801, 1, 1))
      expect(subject.latest).to eq(Date.new(1900, 12, 31))
      expect(subject.earliest_at_granularity).to eq(1801)
      expect(subject.latest_at_granularity).to eq(1900)
      expect(subject.lexeme).to eq('19 century')
      expect(subject.literal).to eq(19)
    end
  end

  context 'with textual century name (19th) and partial indicator: early' do
    let(:args) { {literal: 19, century_type: :name, partial_indicator: 'early'} }

    it 'returns expected values' do
      expect(subject.type).to eq(:century_date_type)
      expect(subject.earliest).to eq(Date.new(1801, 1, 1))
      expect(subject.latest).to eq(Date.new(1834, 12, 31))
      expect(subject.earliest_at_granularity).to eq(1801)
      expect(subject.latest_at_granularity).to eq(1834)
      expect(subject.lexeme).to eq('19 century')
      expect(subject.literal).to eq(19)
    end
  end

  context 'with textual century name (19th) and partial indicator: mid' do
    let(:args) { {literal: 19, century_type: :name, partial_indicator: 'mid'} }

    it 'returns expected values' do
      expect(subject.type).to eq(:century_date_type)
      expect(subject.earliest).to eq(Date.new(1834, 1, 1))
      expect(subject.latest).to eq(Date.new(1867, 12, 31))
      expect(subject.earliest_at_granularity).to eq(1834)
      expect(subject.latest_at_granularity).to eq(1867)
      expect(subject.lexeme).to eq('19 century')
      expect(subject.literal).to eq(19)
    end
  end

  context 'with textual century name (19th) and partial indicator: late' do
    let(:args) { {literal: 19, century_type: :name, partial_indicator: 'late'} }

    it 'returns expected values' do
      expect(subject.type).to eq(:century_date_type)
      expect(subject.earliest).to eq(Date.new(1867, 1, 1))
      expect(subject.latest).to eq(Date.new(1900, 12, 31))
      expect(subject.earliest_at_granularity).to eq(1867)
      expect(subject.latest_at_granularity).to eq(1900)
      expect(subject.lexeme).to eq('19 century')
      expect(subject.literal).to eq(19)
    end
  end

  context 'with plural century name (1900s)' do
    let(:args) { {literal: 19, century_type: :plural} }

    it 'returns expected values' do
      expect(subject.type).to eq(:century_date_type)
      expect(subject.earliest).to eq(Date.new(1900, 1, 1))
      expect(subject.latest).to eq(Date.new(1999, 12, 31))
      expect(subject.earliest_at_granularity).to eq(1900)
      expect(subject.latest_at_granularity).to eq(1999)
      expect(subject.lexeme).to eq('1900s')
      expect(subject.literal).to eq(19)
    end
  end

  context 'with plural century name (1900s) and partial indicator: early' do
    let(:args) { {literal: 19, century_type: :plural, partial_indicator: 'early'} }

    it 'returns expected values' do
      expect(subject.type).to eq(:century_date_type)
      expect(subject.earliest).to eq(Date.new(1900, 1, 1))
      expect(subject.latest).to eq(Date.new(1933, 12, 31))
      expect(subject.earliest_at_granularity).to eq(1900)
      expect(subject.latest_at_granularity).to eq(1933)
      expect(subject.lexeme).to eq('1900s')
      expect(subject.literal).to eq(19)
    end
  end

  context 'with plural century name (1900s) and partial indicator: mid' do
    let(:args) { {literal: 19, century_type: :plural, partial_indicator: 'mid'} }

    it 'returns expected values' do
      expect(subject.type).to eq(:century_date_type)
      expect(subject.earliest).to eq(Date.new(1933, 1, 1))
      expect(subject.latest).to eq(Date.new(1966, 12, 31))
      expect(subject.earliest_at_granularity).to eq(1933)
      expect(subject.latest_at_granularity).to eq(1966)
      expect(subject.lexeme).to eq('1900s')
      expect(subject.literal).to eq(19)
    end
  end

  context 'with plural century name (1900s) and partial indicator: late' do
    let(:args) { {literal: 19, century_type: :plural, partial_indicator: 'late'} }

    it 'returns expected values' do
      expect(subject.type).to eq(:century_date_type)
      expect(subject.earliest).to eq(Date.new(1966, 1, 1))
      expect(subject.latest).to eq(Date.new(1999, 12, 31))
      expect(subject.earliest_at_granularity).to eq(1966)
      expect(subject.latest_at_granularity).to eq(1999)
      expect(subject.lexeme).to eq('1900s')
      expect(subject.literal).to eq(19)
    end
  end

  context 'with uncertainty_digit century (19uu)' do
    let(:args) { {literal: 19, century_type: :uncertainty_digits} }

    it 'returns expected values' do
      expect(century.earliest).to eq(Date.new(1900, 1, 1))
      expect(century.latest).to eq(Date.new(1999, 12, 31))
      expect(century.lexeme).to eq('19uu')
    end
  end
end
