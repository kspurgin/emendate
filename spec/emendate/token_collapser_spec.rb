# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::TokenCollapser do
  subject(:step){ described_class }

  describe '.call' do
    let(:tokens){ prepped_for(string: string, target: step) }
    let(:result) do
      step.call(tokens)
          .value!
          .type_string
    end

    context 'with Jan. 21, 2014' do
      let(:string){ 'Jan. 21, 2014' }

      it 'collapses spaces after single dot, comma' do
        expect(result).to eq('month_alpha number1or2 comma number4')
      end
    end

    context 'with 2014.0' do
      let(:string){ '2014.0' }

      it 'drops `.0` at end' do
        expect(result).to eq('number4')
      end
    end

    context 'with 3/2020' do
      let(:string){ '3/2020' }

      it 'collapse slash into 3' do
        expect(result).to eq('number1or2 number4')
      end
    end

    context 'with "pre-1750"' do
      let(:string){ 'pre-1750' }

      it 'collapses - into pre' do
        expect(result).to eq('before number4')
      end
    end

    context 'with "mid-1750"' do
      let(:string){ 'mid-1750' }

      it 'collapses - into mid' do
        expect(result).to eq('partial number4')
      end
    end

    context "with `1800's`" do
      let(:string){ %(1800's) }

      it 'collapses apostrophe into s' do
        expect(result).to eq('number4 letter_s')
      end
    end

    context 'with `1985 (?)`' do
      let(:string){ '1985 (?)' }

      it 'collapses (?) into ?' do
        expect(result).to eq('number4 question')
      end
    end
  end
end
