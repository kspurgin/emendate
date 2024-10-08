# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::Translators::Collectionspace::KnownUnknown do
  let(:options) do
    {
      dialect: :collectionspace
    }
  end
  let(:translation) { Emendate.translate(str, options) }
  let(:value) { translation.values[0] }
  let(:warnings) { translation.warnings }

  context "with unknown" do
    let(:str) { "unknown" }
    let(:expected) do
      {
        dateDisplayDate: str,
        scalarValuesComputed: "false",
        dateEarliestSingleCertainty: "Unknown"
      }
    end
    it "translates as expected" do
      expect(value).to eq(expected)
      expect(warnings).to be_empty
    end
  end

  context "with n.d." do
    let(:str) { "n.d." }
    let(:expected) do
      {
        dateDisplayDate: str,
        scalarValuesComputed: "false",
        dateEarliestSingleCertainty: "No date"
      }
    end
    it "translates as expected" do
      expect(value).to eq(expected)
      expect(warnings).to be_empty
    end
  end
end
