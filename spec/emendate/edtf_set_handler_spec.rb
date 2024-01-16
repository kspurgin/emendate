# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::EdtfSetHandler do
  subject { described_class.call(tokens) }

  let(:tokens) { prepped_for(string: string, target: described_class) }
  let(:result) { subject.value! }

  context "with edtf handling for square brackets" do
    before do
      Emendate.config.options.square_bracket_interpretation = :edtf_set
    end

    context "with nested bracket" do
      let(:string) { "[1667,1668,[1670]..1672]" }

      it "returns failure" do
        expect(subject).to be_a(Dry::Monads::Failure)
        expect(subject.failure).to eq(:invalid_edtf_set)
      end
    end

    context "with [1667,1668,1670..1672]" do
      let(:string) { "[1667,1668,1670..1672]" }

      it "has expected lexeme" do
        expect(result.lexeme).to eq(string)
        expect(result.set_type).to eq(:alternate)
        expected = "number4 comma number4 comma number4 double_dot number4"
        expect(result.type_string).to eq(expected)
      end
    end

    context "with [1997 or 1999]" do
      let(:string) { "[1997 or 1999]" }

      it "returns failure" do
        expect(subject).to be_a(Dry::Monads::Failure)
        expect(subject.failure).to eq(:invalid_edtf_set)
      end
    end
  end

  context "with [1997 or 1999] and inferred handling" do
    before do
      Emendate.config.options.square_bracket_interpretation = :inferred_date
    end

    let(:string) { "[1997 or 1999]" }

    it "passes the result through" do
      expect(result.lexeme).to eq(string)
      expect(result.set_type).to be_nil
      expect(result.type_string).to eq(tokens.type_string)
    end
  end

  context "with {1667,1668,1670..1672}" do
    let(:string) { "{1667,1668,1670..1672}" }

    it "has expected lexeme" do
      expect(result.lexeme).to eq(string)
      expect(result.set_type).to eq(:inclusive)
      expected = "number4 comma number4 comma number4 double_dot number4"
      expect(result.type_string).to eq(expected)
    end
  end
end
