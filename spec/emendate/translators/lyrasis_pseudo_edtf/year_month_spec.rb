# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::Translators::LyrasisPseudoEdtf::YearMonth do
  let(:options) do
    {dialect: :lyrasis_pseudo_edtf, ambiguous_month_year: :as_month}
  end
  let(:translation) { Emendate.translate(str, options) }
  let(:value) { translation.values[0] }
  let(:warnings) { translation.warnings }

  context "with 2002-10" do
    let(:str) { "2002-10" }
    it "translates as expected" do
      expect(value).to eq("2002-10")
      # rubocop:todo Layout/LineLength
      expect(warnings).to eq(["Ambiguous year + month/season/year treated as_month"])
      # rubocop:enable Layout/LineLength
    end
  end

  context "with ca. 2002-10" do
    let(:str) { "ca. 2002-10" }
    it "translates as expected" do
      expect(value).to eq("2002-10 (approximate)")
      # rubocop:todo Layout/LineLength
      expect(warnings).to eq(["Ambiguous year + month/season/year treated as_month"])
      # rubocop:enable Layout/LineLength
    end
  end

  context "with 3/2020" do
    let(:str) { "3/2020" }
    it "translates as expected" do
      expect(value).to eq("2020-03")
    end
  end
end
