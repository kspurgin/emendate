# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::Translators::LyrasisPseudoEdtf::YearMonthDay do
  let(:options) do
    {dialect: :lyrasis_pseudo_edtf, ambiguous_month_year: :as_month}
  end
  let(:translation) { Emendate.translate(str, options) }
  let(:value) { translation.values[0] }
  let(:warnings) { translation.warnings }

  context "with 2020, Feb 15" do
    let(:str) { "2020, Feb 15" }
    it "translates as expected" do
      expect(value).to eq("2020-02-15")
    end
  end
end
