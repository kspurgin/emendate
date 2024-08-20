# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::Translators::LyrasisPseudoEdtf::KnownUnknown do
  let(:translation) { Emendate.translate(str, **options) }
  let(:value) { translation.values[0] }
  let(:warnings) { translation.warnings }
  let(:options) { {dialect: :lyrasis_pseudo_edtf} }

  context "with n.d." do
    let(:str) { "n.d." }

    it "translates as expected" do
      expect(value).to eq("no date")
      expect(warnings).to be_empty
    end
  end

  context "with unknown" do
    let(:str) { "unknown" }

    it "translates as expected" do
      expect(value).to eq("unknown date")
      expect(warnings).to be_empty
    end
  end
end
