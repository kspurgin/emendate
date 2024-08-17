# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::ProcessingManager do
  subject(:pm) { described_class }

  describe ".call" do
    let(:opt) { {} }
    let(:result) { pm.call(string, opt) }

    context "with untokenizable" do
      let(:string) { "Sometime in 2022" }

      it "returns as expected" do
        expect(result).to be_a(Dry::Monads::Failure)
        res = result.failure
        expect(res.state).to eq(:untokenizable_tagged_failure)
        expect(res.warnings.length).to eq(1)
        expect(res.errors.length).to eq(0)
        expect(res.tokens.type_string).to eq("untokenizable_date_type")
      end
    end

    context "with unprocessable" do
      let(:string) { "1XXX-XX" }

      it "returns as expected" do
        expect(result).to be_a(Dry::Monads::Failure)
        res = result.failure
        expect(res.state).to eq(:unprocessable_tagged_failure)
        expect(res.warnings.length).to eq(1)
        expect(res.errors.length).to eq(1)
      end
    end

    context "with known_unknown" do
      let(:string) { "n.d." }

      it "returns as expected" do
        expect(result).to be_a(Dry::Monads::Failure)
        res = result.failure
        expect(res.state).to eq(:known_unknown_tagged_failure)
        expect(res.warnings.length).to eq(0)
        expect(res.errors.length).to eq(0)
      end
    end

    context "with untaggable date (Feb. 30)" do
      let(:string) { "February 30, 2020" }

      it "returns as expected" do
        expect(result).to be_a(Dry::Monads::Failure)
        res = result.failure
        expect(res.errors.length).to eq(1)
      end
    end
  end
end
