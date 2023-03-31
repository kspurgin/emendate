# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DateTypes::KnownUnknown do
  let(:children){ Emendate.lex(str).segments }
  let(:klass){ described_class.new(lexeme: str, children: children) }

  context 'with n.d.' do
    let(:str){ 'n.d.' }

    it 'returns expected values', :aggregate_failures do
      expect(klass.earliest).to be_nil
      expect(klass.latest).to be_nil
      expect(klass.lexeme).to eq(str)
      expect(klass.literal).to eq(str)
      expect(klass.range?).to be false
      expect(klass.location.col).to eq(0)
      expect(klass.location.length).to eq(6)
    end
  end
end
