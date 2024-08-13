# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::Translators::Edtf::KnownUnknown do
  let(:options) do
    {
      dialect: :edtf,
      unknown_date_output: :custom,
      unknown_date_output_string: "not dated"
    }
  end
  let(:translation) { Emendate.translate(str, options) }
  let(:value) { translation.values[0] }
  let(:warnings) { translation.warnings }

  context "with unknown" do
    let(:str) { "unknown" }
    it "translates as expected" do
      expect(value).to eq("XXXX")
      expect(warnings).to be_empty
    end
  end
end
