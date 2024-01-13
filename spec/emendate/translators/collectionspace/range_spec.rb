# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::Translators::Collectionspace::Range do
  let(:options) { {dialect: :collectionspace} }
  let(:translation) { Emendate.translate(str, options) }
  let(:value) { translation.values[0] }
  let(:warnings) { translation.warnings[0] }

  context "with 1603-1868" do
    let(:str) { "1603-1868" }
    let(:expected) do
      {
        dateDisplayDate: "1603-1868",
        scalarValuesComputed: "true",
        dateEarliestScalarValue: "1603-01-01T00:00:00.000Z",
        dateEarliestSingleYear: "1603",
        dateEarliestSingleMonth: "1",
        dateEarliestSingleDay: "1",
        dateEarliestSingleEra: "CE",
        dateLatestScalarValue: "1868-12-31T00:00:00.000Z",
        dateLatestYear: "1868",
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

  context "with 1880-1890s" do
    let(:str) { "1880-1890s" }
    let(:expected) do
      {
        dateDisplayDate: "1880-1890s",
        scalarValuesComputed: "true",
        dateEarliestScalarValue: "1880-01-01T00:00:00.000Z",
        dateEarliestSingleYear: "1880",
        dateEarliestSingleMonth: "1",
        dateEarliestSingleDay: "1",
        dateEarliestSingleEra: "CE",
        dateLatestScalarValue: "1899-12-31T00:00:00.000Z",
        dateLatestYear: "1899",
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

  context "with `1930s & 1940s`" do
    let(:str) { "1930s & 1940s" }
    let(:expected) do
      {
        dateDisplayDate: "1930s & 1940s",
        scalarValuesComputed: "true",
        dateEarliestScalarValue: "1930-01-01T00:00:00.000Z",
        dateEarliestSingleYear: "1930",
        dateEarliestSingleMonth: "1",
        dateEarliestSingleDay: "1",
        dateEarliestSingleEra: "CE",
        dateLatestScalarValue: "1949-12-31T00:00:00.000Z",
        dateLatestYear: "1949",
        dateLatestMonth: "12",
        dateLatestDay: "31",
        dateLatestEra: "CE"
      }
    end
    it "translates as expected" do
      expect(value).to eq(expected)
      expect(warnings.flatten).to be_empty
    end
  end

  context "with `1930s or 1940s`" do
    let(:str) { "1930s or 1940s" }
    let(:expected) do
      {
        dateDisplayDate: "1930s or 1940s",
        scalarValuesComputed: "true",
        dateEarliestScalarValue: "1930-01-01T00:00:00.000Z",
        dateEarliestSingleYear: "1930",
        dateEarliestSingleMonth: "1",
        dateEarliestSingleDay: "1",
        dateEarliestSingleEra: "CE",
        dateLatestScalarValue: "1949-12-31T00:00:00.000Z",
        dateLatestYear: "1949",
        dateLatestMonth: "12",
        dateLatestDay: "31",
        dateLatestEra: "CE"
      }
    end
    it "translates as expected" do
      expect(value).to eq(expected)
      expect(warnings.flatten).to be_empty
    end
  end

  context "with `1932-1942 or 1948-1949`" do
    let(:str) { "1932-1942 or 1948-1949" }
    let(:expected) do
      {
        dateDisplayDate: "1932-1942 or 1948-1949",
        scalarValuesComputed: "true",
        dateEarliestScalarValue: "1932-01-01T00:00:00.000Z",
        dateEarliestSingleYear: "1932",
        dateEarliestSingleMonth: "1",
        dateEarliestSingleDay: "1",
        dateEarliestSingleEra: "CE",
        dateLatestScalarValue: "1949-12-31T00:00:00.000Z",
        dateLatestYear: "1949",
        dateLatestMonth: "12",
        dateLatestDay: "31",
        dateLatestEra: "CE"
      }
    end
    it "translates as expected" do
      expect(value).to eq(expected)
      expect(warnings.flatten).to be_empty
    end
  end
end
