# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::Translators::Edtf::Century do
  let(:options) { {dialect: :edtf} }
  let(:translation) { Emendate.translate(str, options) }
  let(:value) { translation.values[0] }
  let(:warnings) { translation.warnings[0] }

  context "with 19th c." do
    let(:str) { "19th c." }
    it "translates as expected" do
      expect(value).to eq("{1801..1900}")
      expect(warnings).to eq([])
    end
  end

  context "with 19uu" do
    let(:str) { "19uu" }
    it "translates as expected" do
      expect(value).to eq("19XX")
      expect(warnings).to eq([])
    end
  end
end
