# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::Translators::LyrasisPseudoEdtf::Century do
  let(:options) { {dialect: :lyrasis_pseudo_edtf} }
  let(:translation) { Emendate.translate(str, options) }
  let(:value) { translation.values[0] }
  let(:warnings) { translation.warnings[0] }

  context "with 19th c." do
    let(:str) { "19th c." }
    it "translates as expected" do
      expect(value).to eq("1801 - 1900 (entire range)")
      expect(warnings).to eq([])
    end
  end

  context "with 19XX" do
    let(:str) { "19XX" }
    it "translates as expected" do
      expect(value).to eq("1900 - 1999 (single date in range)")
      expect(warnings).to eq([])
    end
  end
end
