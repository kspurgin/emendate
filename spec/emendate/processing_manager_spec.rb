# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::ProcessingManager do
  subject(:pm){ described_class }

  describe '.call' do
    let(:opt){ {} }
    let(:result){ pm.call(string, opt) }

    context 'with untokenizable' do
      let(:string){ 'Sometime in 2022' }

      it 'returns as expected' do
        expect(result).to be_a(Dry::Monads::Failure)
        res = result.failure
        expect(res.state).to eq(:untokenizable_tagged_failure)
        expect(res.warnings.length).to eq(1)
        expect(res.errors.length).to eq(1)
      end
    end
  end
end
