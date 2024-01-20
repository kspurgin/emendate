# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::Translators::Collectionspace::Century do
  let(:options) { {dialect: :collectionspace} }
  let(:translation) { Emendate.translate(str, options) }
  let(:value) { translation.values[0] }
  let(:base) do
    {
      dateDisplayDate: str,
      scalarValuesComputed: "true",
      dateEarliestScalarValue: "1801-01-01T00:00:00.000Z",
      dateEarliestSingleYear: "1801",
      dateEarliestSingleMonth: "1",
      dateEarliestSingleDay: "1",
      dateEarliestSingleEra: "CE",
      dateLatestScalarValue: "1900-12-31T00:00:00.000Z",
      dateLatestYear: "1900",
      dateLatestMonth: "12",
      dateLatestDay: "31",
      dateLatestEra: "CE"
    }
  end
  let(:warnings) { translation.warnings[0] }

  context "with 19th Century" do
    let(:str) { "19th Century" }

    it "translates as expected" do
      expect(value).to eq(base)
      expect(warnings).to be_empty
    end
  end

  context "with early 19th Century" do
    let(:str) { "early 19th Century" }
    let(:expected) do
      base.merge({
        dateLatestScalarValue: "1834-12-31T00:00:00.000Z",
        dateLatestYear: "1834"
      })
    end

    it "translates as expected" do
      expect(value).to eq(expected)
      expect(warnings).to be_empty
    end
  end

  context "with 19th or 20th Century" do
    let(:str) { "19th or 20th Century" }
    let(:expected) do
      base.merge({
        dateLatestScalarValue: "2000-12-31T00:00:00.000Z",
        dateLatestYear: "2000"
      })
    end

    it "translates as expected" do
      expect(value).to eq(expected)
      expect(warnings).to be_empty
    end
  end
end
