# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::Translators::Collectionspace::Year do
  let(:options) { {dialect: :collectionspace} }
  let(:translation) { Emendate.translate(str, options) }
  let(:year) { "2012" }
  let(:result) { translation.values[0] }
  let(:base) do
    {
      dateDisplayDate: str,
      scalarValuesComputed: "true",
      dateEarliestScalarValue: "2012-01-01T00:00:00.000Z",
      dateEarliestSingleYear: "2012",
      dateEarliestSingleMonth: "1",
      dateEarliestSingleDay: "1",
      dateEarliestSingleEra: "CE",
      dateLatestScalarValue: "2012-12-31T00:00:00.000Z",
      dateLatestYear: "2012",
      dateLatestMonth: "12",
      dateLatestDay: "31",
      dateLatestEra: "CE"
    }
  end
  let(:before_base) do
    {
      dateDisplayDate: str,
      scalarValuesComputed: "true",
      dateLatestScalarValue: "2012-01-02T00:00:00.000Z",
      dateLatestYear: "2012",
      dateLatestMonth: "1",
      dateLatestDay: "1",
      dateLatestEra: "CE",
      dateLatestCertainty: "Before"
    }
  end
  let(:warnings) { translation.warnings }

  context "with 2012" do
    let(:str) { year }

    it "translates as expected" do
      expect(result).to eq(base)
      expect(warnings).to be_empty
    end
  end

  context "with 2012?" do
    let(:str) { "#{year}?" }
    let(:expected) do
      base.merge({
        dateEarliestSingleCertainty: "Uncertain",
        dateLatestCertainty: "Uncertain"
      })
    end

    it "translates as expected" do
      expect(result).to eq(expected)
      expect(warnings).to be_empty
    end
  end

  context "with possibly c. 2012" do
    let(:str) { "possibly c. #{year}" }
    let(:expected) do
      base.merge({
        dateEarliestSingleCertainty: "Circa, possibly",
        dateLatestCertainty: "Circa, possibly"
      })
    end

    it "translates as expected" do
      expect(result).to eq(expected)
      expect(warnings).to be_empty
    end
  end

  context "with 2012 (probably)" do
    let(:str) { "#{year} (probably)" }
    let(:expected) do
      base.merge({
        dateEarliestSingleCertainty: "Probably",
        dateLatestCertainty: "Probably"
      })
    end

    it "translates as expected" do
      expect(result).to eq(expected)
      expect(warnings).to be_empty
    end
  end

  context "with 2012 B.C." do
    let(:str) { "#{year} B.C." }
    let(:expected) do
      base.merge({
        dateEarliestSingleEra: "BCE",
        dateLatestEra: "BCE"
      })
    end

    it "translates as expected" do
      expect(result).to eq(expected)
      expect(warnings).to be_empty
    end
  end

  context "with pre-2012" do
    let(:str) { "pre-#{year}" }

    it "translates as expected" do
      expect(result).to eq(before_base)
      expect(warnings).to be_empty
    end
  end

  context "with before 2012 B.C." do
    let(:str) { "before #{year} B.C." }
    let(:expected) do
      before_base.merge({
        dateLatestEra: "BCE"
      })
    end

    it "translates as expected" do
      expect(result).to eq(expected)
      expect(warnings).to be_empty
    end
  end

  context "with after 2012" do
    let(:str) { "after #{year}" }
    let(:expected) do
      base.merge({
        dateEarliestScalarValue: "#{year}-12-31T00:00:00.000Z",
        dateEarliestSingleMonth: "12",
        dateEarliestSingleDay: "31",
        dateEarliestSingleCertainty: "After",
        dateLatestScalarValue: "2023-12-02T00:00:00.000Z",
        dateLatestYear: "2023",
        dateLatestMonth: "12",
        dateLatestDay: "2",
        dateLatestCertainty: "After"
      })
    end

    it "translates as expected" do
      allow(Date).to receive(:today).and_return(Date.new(2023, 12, 2))
      expect(result).to eq(expected)
      expect(warnings).to be_empty
    end
  end
end
