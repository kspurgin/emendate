# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::AlphaMonthConverter do
  subject(:step){ described_class }

  describe '.call' do
    let(:tokens){ prepped_for(string: string, target: step) }
    let(:result) do
      step.call(tokens)
        .value!
    end

    context 'with month abbreviation' do
      let(:string){ 'Jan 2021' }

      it 'tags as expected' do
        segment = result.first
        expect(segment.type).to eq(:month)
        expect(segment.lexeme).to eq('jan')
        expect(segment.literal).to eq(1)
        expect(segment.location.col).to eq(0)
        expect(segment.location.length).to eq(4)
      end
    end

    context 'with month full' do
      let(:string){ 'October 2021' }

      it 'tags as expected' do
        segment = result.first
        expect(segment.type).to eq(:month)
        expect(segment.lexeme).to eq('october')
        expect(segment.literal).to eq(10)
        expect(segment.location.col).to eq(0)
        expect(segment.location.length).to eq(8)
      end
    end

    context 'with 2020, summer' do
      let(:string){ '2020, summer' }

      it 'tags as expected' do
        segment = result.last
        expect(segment.type).to eq(:season)
        expect(segment.lexeme).to eq('summer')
        expect(segment.literal).to eq(22)
      end
    end
  end
end
