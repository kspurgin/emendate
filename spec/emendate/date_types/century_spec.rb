# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DateTypes::Century do
  subject{ described_class.new(**args) }

  let(:tokens) do
    Emendate.prepped_for(string: str, target: Emendate::DateSegmenter)
  end
  let(:baseargs){ { sources: tokens } }
  let(:args){ baseargs }

  context 'when :name type' do
    let(:str){ '19th century' }
    let(:args){ baseargs }

    it 'returns expected values' do
      expect(subject.type).to eq(:century_date_type)
      expect(subject.century_type).to eq(:name)
      expect(subject.lexeme).to eq(str)
      expect(subject.literal).to eq(18)
      expect(subject.earliest).to eq(Date.new(1801, 1, 1))
      expect(subject.latest).to eq(Date.new(1900, 12, 31))
      expect(subject.earliest_at_granularity).to eq(1801)
      expect(subject.latest_at_granularity).to eq(1900)
    end

    context 'with partial indicator' do
      let(:args){ baseargs.merge({ partial_indicator: ind }) }

      context 'when early' do
        let(:ind){ :early }

        it 'returns expected values' do
          expect(subject.earliest).to eq(Date.new(1801, 1, 1))
          expect(subject.latest).to eq(Date.new(1834, 12, 31))
          expect(subject.earliest_at_granularity).to eq(1801)
          expect(subject.latest_at_granularity).to eq(1834)
        end
      end

      context 'when mid' do
        let(:ind){ :mid }

        it 'returns expected values' do
          expect(subject.earliest).to eq(Date.new(1834, 1, 1))
          expect(subject.latest).to eq(Date.new(1867, 12, 31))
          expect(subject.earliest_at_granularity).to eq(1834)
          expect(subject.latest_at_granularity).to eq(1867)
        end
      end

      context 'when late' do
        let(:ind){ :late }

        it 'returns expected values' do
          expect(subject.earliest).to eq(Date.new(1867, 1, 1))
          expect(subject.latest).to eq(Date.new(1900, 12, 31))
          expect(subject.earliest_at_granularity).to eq(1867)
          expect(subject.latest_at_granularity).to eq(1900)
        end
      end
    end
  end

  context 'with :plural type' do
    let(:str){ '1900s' }
    let(:args){ baseargs.merge({ sources: tokens }) }

    it 'returns expected values' do
      expect(subject.type).to eq(:century_date_type)
      expect(subject.century_type).to eq(:plural)
      expect(subject.lexeme).to eq(str)
      expect(subject.literal).to eq(19)
      expect(subject.earliest).to eq(Date.new(1900, 1, 1))
      expect(subject.latest).to eq(Date.new(1999, 12, 31))
      expect(subject.earliest_at_granularity).to eq(1900)
      expect(subject.latest_at_granularity).to eq(1999)
    end

    context 'with partial indicator' do
      let(:args){ baseargs.merge({ partial_indicator: ind }) }

      context 'when early' do
        let(:ind){ :early }

        it 'returns expected values' do
          expect(subject.earliest).to eq(Date.new(1900, 1, 1))
          expect(subject.latest).to eq(Date.new(1933, 12, 31))
          expect(subject.earliest_at_granularity).to eq(1900)
          expect(subject.latest_at_granularity).to eq(1933)
        end
      end

      context 'when mid' do
        let(:ind){ :mid }

        it 'returns expected values' do
          expect(subject.earliest).to eq(Date.new(1933, 1, 1))
          expect(subject.latest).to eq(Date.new(1966, 12, 31))
          expect(subject.earliest_at_granularity).to eq(1933)
          expect(subject.latest_at_granularity).to eq(1966)
        end
      end

      context 'when late' do
        let(:ind){ :late }

        it 'returns expected values' do
          expect(subject.earliest).to eq(Date.new(1966, 1, 1))
          expect(subject.latest).to eq(Date.new(1999, 12, 31))
          expect(subject.earliest_at_granularity).to eq(1966)
          expect(subject.latest_at_granularity).to eq(1999)
        end
      end
    end
  end

  context 'with :uncertainty_digits type' do
    let(:str){ '19uu' }
    let(:args){ baseargs.merge({ sources: tokens }) }

    it 'returns expected values' do
      expect(subject.type).to eq(:century_date_type)
      expect(subject.century_type).to eq(:uncertainty_digits)
      expect(subject.lexeme).to eq(str)
      expect(subject.literal).to eq(19)
      expect(subject.earliest).to eq(Date.new(1900, 1, 1))
      expect(subject.latest).to eq(Date.new(1999, 12, 31))
      expect(subject.earliest_at_granularity).to eq(1900)
      expect(subject.latest_at_granularity).to eq(1999)
    end
  end
end
