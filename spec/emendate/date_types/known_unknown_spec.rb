# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DateTypes::KnownUnknown do
  subject(:klass){ described_class.new(sources: sources) }

  let(:sources) do
    Emendate.prepped_for(
      string: str,
      target: Emendate::KnownUnknownTagger
    )
  end

  context 'with n.d.' do
    let(:str){ 'n.d.' }

    it 'returns expected values', :aggregate_failures do
      expect(klass.earliest).to be_nil
      expect(klass.latest).to be_nil
      expect(klass.lexeme).to eq(str)
      expect(klass.literal).to eq(str)
      expect(klass.range?).to be false
      expect(klass.location.col).to eq(0)
      expect(klass.location.length).to eq(4)
    end

    context 'with custom output string' do
      before(:context) do
        Emendate.config.options.unknown_date_output = :custom
        Emendate.config.options.unknown_date_output_string = 'val'
      end

      after(:context){ Emendate.reset_config }

      it 'returns expected values', :aggregate_failures do
        expect(klass.lexeme).to eq('val')
      end
    end
  end
end
