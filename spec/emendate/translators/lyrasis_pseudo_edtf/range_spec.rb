# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::Translators::LyrasisPseudoEdtf::Range do
  let(:options) do
    {dialect: :lyrasis_pseudo_edtf, ambiguous_month_year: :as_year}
  end
  let(:translation) { Emendate.translate(str, options) }
  let(:value) { translation.values[0] }
  let(:warnings) { translation.warnings }

  context "with 1910-11" do
    let(:str) { "1910-11" }
    it "translates as expected" do
      expect(value).to eq("1910 - 1911")
      expect(warnings).to eq([
        "Ambiguous year + month/season/year treated as_year"
      ])
    end
  end
end
