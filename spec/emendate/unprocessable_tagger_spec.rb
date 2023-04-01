# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::UnprocessableTagger do
  subject(:tagger){ described_class }

  describe '.call' do
    let(:tokens){ prepped_for(string: string, target: tagger) }
    let(:result){ tagger.call(tokens) }

    context 'when all processable' do
      let(:string){ '1985' }

      it 'passes all through' do
        expect(result).to be_a(Dry::Monads::Success)
        expect(result.value!).to eq(tokens)
      end
    end

    context 'when unprocessable' do
      let(:string){ '1XXX-XX' }

      it 'returns unprocessable' do
        expect(result).to be_a(Dry::Monads::Failure)
        res = result.failure
        expect(res.types).to eq([:unprocessable_date_type])
        warnings = ["Unprocessable string"]
        expect(res.warnings).to eq(warnings)
        expect(res.lexeme).to eq(string)
      end
    end
  end
end
