# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::Translators::Edtf::YearMonth do
  let(:options) { {dialect: :edtf, ambiguous_month_year: :as_month} }
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
      expect(value).to eq("2002-10~")
      # rubocop:todo Layout/LineLength
      expect(warnings).to eq(["Ambiguous year + month/season/year treated as_month"])
      # rubocop:enable Layout/LineLength
    end
  end

  context "with 03/2020" do
    let(:str) { "03/2020" }

    it "translates as expected" do
      expect(value).to eq("2020-03")
    end
  end
end
