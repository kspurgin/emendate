# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::Number do
  let(:t) { described_class.new(lexeme: lexeme) }

  context "with an allowed length" do
    let(:lexeme) { "12" }

    it "sets values as expected" do
      expect(t.type).to eq(:number1or2)
      expect(t.literal).to eq(12)
      expect(t.digits).to eq(2)
    end
  end

  context "when zero" do
    let(:lexeme) { "0" }

    it "sets values as expected" do
      expect(t.type).to eq(:standalone_zero)
      expect(t.literal).to be_nil
      expect(t.digits).to eq(1)
    end
  end

  context "with a disallowed length" do
    let(:lexeme) { "55555" }

    it "sets values as expected" do
      expect(t.type).to eq(:unknown)
      expect(t.literal).to eq(55555)
      expect(t.digits).to eq(5)
    end
  end

  context "when created with non-number lexeme" do
    it "raises error" do
      expect do
        described_class.new(lexeme: "1a")
      end.to raise_error(Emendate::TokenLexemeError)
    end
  end
end
