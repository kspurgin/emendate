# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::UntokenizableTagger do
  subject(:tagger){ described_class }

  describe '.call' do
    let(:tokens){ prepped_for(string: string, target: tagger) }
    let(:result){ tagger.call(tokens) }

    context 'when all tokenizable' do
      let(:string){ '1985' }

      it 'passes all through' do
        expect(result).to be_a(Dry::Monads::Success)
        expect(result.value!).to eq(tokens)
      end
    end

    context 'when untokenizable' do
      let(:string){ 'Sometime in 1985' }

      it 'returns untokenizable' do
        expect(result).to be_a(Dry::Monads::Failure)
        res = result.failure
        expect(res.types).to eq([:untokenizable_date_type])
        warnings = ["Untokenizable sequences: sometime; in"]
        expect(res.warnings).to eq(warnings)
        expect(res.lexeme).to eq(string.downcase)
      end
    end
  end
end
