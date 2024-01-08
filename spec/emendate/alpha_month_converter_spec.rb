# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::AlphaMonthConverter do
  subject{ described_class.call(tokens).value! }

  describe '.call' do
    let(:tokens){ prepped_for(string: string, target: described_class) }

    context 'with month abbreviation' do
      let(:string){ 'Jan 2021' }

      it 'tags as expected' do
        segment = subject.first
        expect(segment.type).to eq(:month)
        expect(segment.lexeme).to eq('Jan ')
        expect(segment.literal).to eq(1)
      end
    end

    context 'with month full' do
      let(:string){ 'October 2021' }

      it 'tags as expected' do
        segment = subject.first
        expect(segment.type).to eq(:month)
        expect(segment.lexeme).to eq('October ')
        expect(segment.literal).to eq(10)
      end
    end

    context 'with 2020, summer' do
      let(:string){ '2020, summer' }

      it 'tags as expected' do
        segment = subject.last
        expect(segment.type).to eq(:season)
        expect(segment.lexeme).to eq('summer')
        expect(segment.literal).to eq(22)
      end
    end
  end
end
