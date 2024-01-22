# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::MonthDayAnalyzer do
  subject(:analyzer) { described_class.new(*args) }

  let(:args) do
    t = Emendate.prepped_for(
      string: str,
      target: Emendate::DatePartTagger
    )
    [t[0], t[1], t[2]]
  end

  describe "#call" do
    let(:result) { analyzer.call }
    let(:month) { result.month.literal }
    let(:day) { result.day.literal }
    let(:warnings) { result.warnings }

    context "with unambiguous month day - 12-31-2020" do
      let(:str) { "12-31-2020" }

      it "returns expected" do
        expect(month).to eq(12)
        expect(day).to eq(31)
        expect(warnings).to be_empty
      end
    end

    context "with unambiguous day month - 31-12-2020" do
      let(:str) { "31-12-2020" }

      it "returns expected" do
        expect(month).to eq(12)
        expect(day).to eq(31)
        expect(warnings).to be_empty
      end
    end

    context "with ambiguous - 02-03-2020" do
      let(:str) { "02-03-2020" }

      it "returns expected" do
        expect(month).to eq(2)
        expect(day).to eq(3)
        expect(warnings.length).to eq(1)
      end

      context "when as_day_month" do
        before { Emendate.options.ambiguous_month_day = :as_day_month }

        it "returns expected" do
          expect(month).to eq(3)
          expect(day).to eq(2)
          expect(warnings.length).to eq(1)
        end
      end

      context "with invalid - 31-29-2020" do
        let(:str) { "31-29-2020" }

        it "raises error" do
          expect { result }.to raise_error(Emendate::MonthDayError)
        end
      end
    end
  end
end
