# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::RangeIndicator do
  subject(:step){ described_class }

  let(:tokens){ prepped_for(string: str, target: step) }

  describe '.call' do
    let(:result) do
      step.call(tokens)
        .value!
    end
    let(:type_string){ result.type_string }

    context 'without range present (circa 202127)' do
      let(:str){ 'circa 202127' }

      it 'returns original' do
        expect(type_string).to eq('year_date_type')
      end
    end

    context 'with range present (1972 - 1999)' do
      let(:str){ '1972 - 1999' }

      it 'returns range_date_type' do
        expect(type_string).to eq('range_date_type')
      end
    end

    context 'with mixed range and non-range (1970, 1972 - 1999, 2002)' do
      let(:str){ '1970, 1972 - 1999, 2002' }

      it 'returns range_date_type' do
        expect(type_string).to eq('year_date_type comma range_date_type comma year_date_type')
      end
    end

    context 'with invalid range present (1999 - 1972)' do
      let(:str){ '1999 - 1972' }

      it 'returns range_date_type' do
        expect(type_string).to eq('range_date_type')
        expect(result.warnings.length).to eq(1)
      end
    end
  end
end
