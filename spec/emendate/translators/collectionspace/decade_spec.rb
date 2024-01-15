# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::Translators::Collectionspace::Decade do
  let(:options) do
    {
      dialect: :collectionspace
    }
  end
  let(:translation) { Emendate.translate(str, options) }
  let(:value) { translation.values[0] }
  let(:warnings) { translation.warnings[0] }

  context "with 1800s" do
    let(:str) { "1800s" }
    let(:expected) do
      {
        dateDisplayDate: "1800s",
        scalarValuesComputed: "true",
        dateEarliestScalarValue: "1800-01-01T00:00:00.000Z",
        dateEarliestSingleYear: "1800",
        dateEarliestSingleMonth: "1",
        dateEarliestSingleDay: "1",
        dateEarliestSingleEra: "CE",
        dateLatestScalarValue: "1809-12-31T00:00:00.000Z",
        dateLatestYear: "1809",
        dateLatestMonth: "12",
        dateLatestDay: "31",
        dateLatestEra: "CE"
      }
    end
    it "translates as expected" do
      expect(value).to eq(expected)
      expect(warnings).to eq(
        ["Interpreting pluralized year as decade"]
      )
    end
  end

  context "with c. 1950s", skip: "Fix certainty qualification" do
    let(:str) { "c. 1950s" }
    let(:expected) do
      {
        dateDisplayDate: "c. 1950s",
        scalarValuesComputed: "true",
        dateEarliestScalarValue: "1950-01-01T00:00:00.000Z",
        dateEarliestSingleYear: "1950",
        dateEarliestSingleMonth: "1",
        dateEarliestSingleDay: "1",
        dateEarliestSingleEra: "CE",
        dateEarliestSingleCertainty: "Circa",
        dateLatestScalarValue: "1959-12-31T00:00:00.000Z",
        dateLatestYear: "1959",
        dateLatestMonth: "12",
        dateLatestDay: "31",
        dateLatestEra: "CE",
        dateLatestCertainty: "Circa"
      }
    end
    it "translates as expected" do
      expect(value).to eq(expected)
      expect(warnings).to be_empty
    end
  end

  context "with mid-1940s" do
    let(:str) { "mid-1940s" }
    let(:expected) do
      {
        dateDisplayDate: "mid-1940s",
        scalarValuesComputed: "true",
        dateEarliestScalarValue: "1944-01-01T00:00:00.000Z",
        dateEarliestSingleYear: "1944",
        dateEarliestSingleMonth: "1",
        dateEarliestSingleDay: "1",
        dateEarliestSingleEra: "CE",
        dateLatestScalarValue: "1946-12-31T00:00:00.000Z",
        dateLatestYear: "1946",
        dateLatestMonth: "12",
        dateLatestDay: "31",
        dateLatestEra: "CE"
      }
    end
    it "translates as expected" do
      expect(value).to eq(expected)
      expect(warnings).to be_empty
    end
  end
end
