# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::OrdinalTranslator do
  subject(:step){ described_class }

  describe '.call' do
    let(:tokens){ prepped_for(string: string, target: step) }
    let(:result) do
      step.call(tokens)
        .value!
    end

    context 'with no ordinal indicator' do
      let(:string){ '2000' }

      it 'returns original token set' do
        expect(result.type_string).to eq('number4')
      end
    end

    context 'with ordinal indicator appearing after a 1 or 2 digit number' do
      let(:string){ '20th' }

      it 'removes ordinal indicator' do
        expect(result.type_string).to eq('number1or2')
      end
    end

    context 'with ordinal indicator as first element' do
      let(:string){ 'th20' }

      it 'removes ordinal indicator and warns' do
        expect(result.type_string).to eq('number1or2')
        ex = 'Ordinal indicator unexpectedly appears at beginning of date string'
        expect(result.warnings).to include(ex)
      end
    end

    context 'with ordinal indicator appearing after NOT a 1 or 2 digit number' do
      let(:string){ '22nd to 9999th' }

      it 'removes ordinal indicator and warns' do
        expect(result.type_string).to eq('number1or2 range_indicator number4')
        ex = 'Ordinal indicator expected after :number1or2. Found after :number4'
        expect(result.warnings).to include(ex)
      end
    end
  end
end
