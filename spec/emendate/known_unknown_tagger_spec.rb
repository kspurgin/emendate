# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::KnownUnknownTagger do
  subject(:tagger){ described_class }

  describe '.call' do
    let(:tokens){ prepped_for(string: string, target: tagger) }
    let(:result){ tagger.call(tokens) }

    context 'without unknown' do
      let(:string){ '1984' }

      it 'passes through as expected' do
        expect(result.value!).to eq(tokens)
      end
    end

    context 'with default options (orig unknowndate output) and `n.d.`' do
      let(:string){ 'n.d.' }

      it 'tags as expected' do
        expect(result).to be_a(Dry::Monads::Failure)
        failure = result.failure
        expect(failure.types).to eq(%i[knownunknown_date_type])
        expect(failure[0].lexeme).to eq('n.d.')
      end

      context 'with custom output' do
        after{ Emendate.reset_config }

        it 'tags as expected' do
          opt = {
            unknown_date_output: :custom,
            unknown_date_output_string: 'unknown date'
          }
          Emendate::Options.new(opt)
          failure = result.failure
          expect(failure.types).to eq(%i[knownunknown_date_type])
          expect(failure[0].lexeme).to eq('unknown date')
        end
      end
    end

    context 'with default options (orig unknowndate output) and `Date Unknown`' do
      let(:string){ 'Date Unknown' }

      it 'tags as expected' do
        failure = result.failure
        expect(failure.types).to eq(%i[knownunknown_date_type])
        expect(failure[0].lexeme).to eq('Date Unknown')
      end
    end
  end
end
