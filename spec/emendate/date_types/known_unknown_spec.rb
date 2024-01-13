# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::DateTypes::KnownUnknown do
  subject { described_class.new(sources: sources) }

  let(:sources) do
    Emendate.prepped_for(
      string: str,
      target: Emendate::KnownUnknownTagger
    ).segments
  end

  context "with n.d." do
    let(:str) { "n.d." }

    it "returns expected values" do
      expect(subject.earliest).to be_nil
      expect(subject.latest).to be_nil
      expect(subject.lexeme).to eq(str)
      expect(subject.literal).to be_nil
      expect(subject.range?).to be false
    end

    context "with custom output string" do
      before(:context) do
        Emendate.config.options.unknown_date_output = :custom
        Emendate.config.options.unknown_date_output_string = "val"
      end

      it "returns expected values" do
        expect(subject.lexeme).to eq("val")
      end
    end
  end
end
