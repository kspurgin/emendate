# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::Translators::LyrasisPseudoEdtf::Range do
  let(:options) do
    {dialect: :lyrasis_pseudo_edtf, ambiguous_month_year: :as_year}
  end
  let(:translation) { Emendate.translate(str, options) }
  let(:value) { translation.values[0] }
  let(:warnings) { translation.warnings }

  context "with ####-##" do
    let(:str) { "1910-11" }
    it "translates as expected" do
      expect(value).to eq("1910 - 1911")
      expect(warnings).to eq([
        "Ambiguous year + month/season/year treated as_year"
      ])
    end
  end

  context "with -#### and beginning_hyphen: :unknown" do
    before { Emendate.config.options.beginning_hyphen = :unknown }

    let(:str) { "-1910" }
    it "translates as expected" do
      expect(value).to eq("unknown date - 1910")
      expect(warnings).to be_empty
    end
  end
end
