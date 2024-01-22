# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::AllShortMdyAnalyzer do
  subject(:analyzer) { described_class.new(tokens) }

  let(:tokens) do
    Emendate.prepped_for(string: str, target: Emendate::DatePartTagger)
  end

  describe "#call" do
    let(:result) { analyzer.call }
    let(:ymd) do
      %i[year month day].map { |type| result.when_type(type).first.literal }
        .join(" ")
    end
    let(:wct) { result.warnings.length }

    context "with ##-##-## (all unambiguous)" do
      let(:str) { "87-04-13" }

      it "converts to date types" do
        expect(ymd).to eq("1987 4 13")
        expect(result.lexeme).to eq(str)
        expect(wct).to eq(0)
      end
    end

    context "with ##-##-## (all ambiguous)" do
      let(:str) { "10-02-06" }

      it "converts to date types (default order)" do
        expect(ymd).to eq("2006 10 2")
        expect(wct).to eq(1)
      end

      context "with day month year option" do
        before { Emendate.options.ambiguous_month_day_year = :day_month_year }

        it "converts to date types" do
          expect(ymd).to eq("2006 2 10")
          expect(wct).to eq(1)
        end
      end

      context "with year month day option" do
        before { Emendate.options.ambiguous_month_day_year = :year_month_day }

        it "converts to date types" do
          expect(ymd).to eq("2010 2 6")
          expect(wct).to eq(1)
        end
      end

      context "with year day month option" do
        before { Emendate.options.ambiguous_month_day_year = :year_day_month }

        it "converts to date types" do
          expect(ymd).to eq("2010 6 2")
          expect(wct).to eq(1)
        end
      end
    end

    context "with ##-##-## (ambiguous month/day)" do
      let(:str) { "50-02-03" }

      it "returns day month year (with default options)" do
        expect(ymd).to eq("1950 2 3")
        expect(wct).to eq(1)
      end
    end

    context "with ##-##-## (invalid)" do
      let(:str) { "90-31-29" }

      it "raises error" do
        expect { result }.to raise_error(Emendate::MonthDayYearError)
      end
    end
  end
end
