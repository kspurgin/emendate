# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::TokenReplacer do
  subject(:step){ described_class }

  describe '.call' do
    let(:tokens){ prepped_for(string: string, target: step) }
    let(:result) do
      step.call(tokens)
          .value!
          .type_string
    end

    context 'with possibly about 1990' do
      let(:string){ 'possibly about 1990' }

      it 'replaces about token with derived approximate' do
        expect(result).to eq('uncertain space approximate space number4')
      end
    end
  end
end
