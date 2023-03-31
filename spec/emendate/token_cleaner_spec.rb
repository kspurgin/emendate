# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::TokenCleaner do
  subject(:step){ described_class }

  let(:tokens){ prepped_for(string: str, target: step) }

  describe '.call' do
    let(:result) do
      step.call(tokens)
        .value!
    end
    let(:type_string){ result.type_string }

    context 'when no cleanup needed' do
      let(:str){ 'circa 202127' }

      it 'returns original tokens' do
        expect(type_string).to eq('year_date_type')
      end
    end

    context 'when date_separator present' do
      let(:str){ '1972 or 1975' }

      it 'returns cleaned' do
        expect(type_string).to eq(
          'year_date_type year_date_type'
        )
      end
    end
  end
end
