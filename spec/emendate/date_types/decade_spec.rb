# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DateTypes::Decade do
  subject{ described_class.new(**args) }

  let(:tokens) do
    Emendate.prepped_for(string: str, target: Emendate::DateSegmenter)
  end
  let(:baseargs){ { sources: tokens } }
  let(:args){ baseargs }

  context 'when plural decade' do
    let(:str){ '1990s' }
    let(:args){ baseargs }

    it 'returns expected values' do
      expect(subject.decade_type).to eq(:plural)
      expect(subject.earliest).to eq(Date.new(1990, 1, 1))
      expect(subject.latest).to eq(Date.new(1999, 12, 31))
      expect(subject.lexeme).to eq(str)
      expect(subject.literal).to eq(199)
    end
  end

  context 'when plural and possibly century' do
    let(:str){ '1900s' }
    let(:args){ baseargs }

    it 'returns expected values' do
      expect(subject.earliest).to eq(Date.new(1900, 1, 1))
      expect(subject.latest).to eq(Date.new(1909, 12, 31))
      expect(subject.lexeme).to eq('1900s')
      expect(subject.literal).to eq(190)
    end
  end

  context 'when plural and possibly millennium' do
    let(:str){ '2000s' }
    let(:args){ baseargs }

    it 'returns expected values' do
      expect(subject.earliest).to eq(Date.new(2000, 1, 1))
      expect(subject.latest).to eq(Date.new(2009, 12, 31))
      expect(subject.lexeme).to eq('2000s')
      expect(subject.literal).to eq(200)
    end
  end

  context 'when plural and possibly century with 3 digits' do
    let(:str){ '200s' }
    let(:args){ baseargs }

    it 'returns expected values' do
      expect(subject.earliest).to eq(Date.new(200, 1, 1))
      expect(subject.latest).to eq(Date.new(209, 12, 31))
      expect(subject.lexeme).to eq('200s')
      expect(subject.literal).to eq(20)
    end
  end

  context 'when uncertainty digit decade' do
    let(:str){ '199u' }
    let(:args){ baseargs }

    it 'returns expected values' do
      expect(subject.decade_type).to eq(:uncertainty_digits)
      expect(subject.earliest).to eq(Date.new(1990, 1, 1))
      expect(subject.latest).to eq(Date.new(1999, 12, 31))
      expect(subject.lexeme).to eq(str)
      expect(subject.literal).to eq(199)
    end
  end

  context 'with partial indicator' do
    let(:str){ '1990s' }
    let(:args){ baseargs.merge({ partial_indicator: ind }) }

    context 'when :early' do
      let(:ind){ :early }

      it 'returns expected values' do
        expect(subject.earliest).to eq(Date.new(1990, 1, 1))
        expect(subject.latest).to eq(Date.new(1993, 12, 31))
      end
    end

    context 'when :mid' do
      let(:ind){ :mid }

      it 'returns expected values' do
        expect(subject.earliest).to eq(Date.new(1994, 1, 1))
        expect(subject.latest).to eq(Date.new(1996, 12, 31))
      end
    end

    context 'when :late' do
      let(:ind){ :late }

      it 'returns expected values' do
        expect(subject.earliest).to eq(Date.new(1997, 1, 1))
        expect(subject.latest).to eq(Date.new(1999, 12, 31))
      end
    end
  end
end
