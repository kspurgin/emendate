# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::KnownUnknownTagger do
  subject(:tagger) { described_class }

  describe ".call" do
    let(:tokens) { prepped_for(string: string, target: tagger) }
    let(:result) { tagger.call(tokens) }

    context "without unknown known value" do
      let(:string) { "1984" }

      it "passes through as expected" do
        expect(result.value!).to eq(tokens)
      end
    end

    context "with n.d." do
      let(:string) { "n.d." }

      it "tags as expected" do
        expect(result).to be_a(Dry::Monads::Failure)
        failure = result.failure
        expect(failure.types).to eq(%i[knownunknown_date_type])
        expect(failure[0].category).to eq(:no_date)
      end
    end

    context "with ?" do
      let(:string) { "?" }

      it "tags as expected" do
        expect(result).to be_a(Dry::Monads::Failure)
        failure = result.failure
        expect(failure.types).to eq(%i[knownunknown_date_type])
        expect(failure[0].category).to eq(:unknown_date)
      end
    end

    context "with Date Unknown" do
      let(:string) { "Date Unknown" }

      it "tags as expected" do
        failure = result.failure
        expect(failure.types).to eq(%i[knownunknown_date_type])
        expect(failure[0].category).to eq(:unknown_date)
      end
    end

    context "with unknown" do
      let(:string) { "unknown" }

      it "tags as expected" do
        failure = result.failure

        expect(failure.types).to eq(%i[knownunknown_date_type])
        expect(failure[0].category).to eq(:unknown_date)
      end
    end

    context "with ####-?" do
      let(:string) { "1924-?" }

      it "tags as expected" do
        success = result.value!
        expect(success.types).to eq(
          %i[number4 hyphen unknown_date]
        )
      end
    end
  end
end
