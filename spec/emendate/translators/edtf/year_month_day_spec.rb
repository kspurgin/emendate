# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::Translators::Edtf::YearMonthDay do
  let(:options) { {dialect: :edtf, ambiguous_month_year: :as_month} }
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
