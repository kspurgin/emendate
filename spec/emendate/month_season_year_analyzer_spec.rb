# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::MonthSeasonYearAnalyzer do
  subject(:analyzer) { described_class.new(**tokens) }

  let(:tokens) do
    t = Emendate.prepped_for(
      string: str,
      target: Emendate::DatePartTagger
    )
    {year: t[0], num: t[2]}
  end

  let(:result) { analyzer.call }
  let(:type) { result.result.type }
  let(:literal) { result.result.literal }
  let(:lexeme) { result.result.lexeme }
  let(:warnings) { result.warnings.first }

  context "with 2009-03 (unambiguous year-number - second less than first "\
          "- MONTH)" do
    let(:str) { "2009-03" }

    it "returns month" do
      expect(type).to eq(:month)
      expect(lexeme).to eq("03")
      expect(literal).to eq(3)
      expect(warnings).to be_nil
    end

    context "with ambiguous_month_year: as_year" do
      before { Emendate.config.options.ambiguous_month_year = :as_year }

      it "returns month" do
        expect(type).to eq(:month)
        expect(lexeme).to eq("03")
        expect(literal).to eq(3)
        expect(warnings).to be_nil
      end
    end
  end

  context "with 1995-28 (unambiguous year-number - second less than first "\
          "- SEASON)" do
    let(:str) { "1995-28" }

    it "returns year (default treatment for ambiguous month/year -- "\
       "default month max, invalid range)" do
      expect(type).to eq(:year)
      expect(lexeme).to eq("28")
      expect(literal).to eq(1928)
      expect(warnings).to eq(
        "Ambiguous year + month/season/year treated as_year, but this "\
        "creates invalid range"
      )
    end

    context "with max_month_number_handling: :edtf_level_2" do
      before do
        Emendate.config.options.max_month_number_handling = :edtf_level_2
      end

      it "returns season" do
        expect(type).to eq(:season)
        expect(lexeme).to eq("28")
        expect(literal).to eq(28)
        expect(warnings).to be_nil
      end
    end
  end

  context "with 1995-99 (unambiguous year-number - second >first, cannot "\
          "be month/season, valid range)" do
    let(:str) { "1995-99" }

    it "returns year" do
      expect(type).to eq(:year)
      expect(lexeme).to eq("99")
      expect(literal).to eq(1999)
      expect(warnings).to be_nil
    end
  end

  context "with 2010-12 (ambiguous value)" do
    let(:str) { "2010-12" }

    context "with ambiguous_month_year: :as_year" do
      before { Emendate.config.options.ambiguous_month_year = :as_year }

      it "returns year" do
        expect(type).to eq(:year)
        expect(lexeme).to eq("12")
        expect(literal).to eq(2012)
        expect(warnings).to eq(
          "Ambiguous year + month/season/year treated as_year"
        )
      end
    end

    context "with ambiguous_month_year: :as_month" do
      before { Emendate.config.options.ambiguous_month_year = :as_month }

      it "returns year" do
        expect(type).to eq(:month)
        expect(lexeme).to eq("12")
        expect(literal).to eq(12)
        expect(warnings).to eq(
          "Ambiguous year + month/season/year treated as_month"
        )
      end
    end
  end

  context "with 2010-21 (ambiguous value if EDTF max months)" do
    let(:str) { "2010-21" }

    context "with ambiguous_month_year: :as_year" do
      before { Emendate.config.options.ambiguous_month_year = :as_year }

      it "returns year" do
        expect(type).to eq(:year)
        expect(lexeme).to eq("21")
        expect(literal).to eq(2021)
        expect(warnings).to be_nil # cannot be month, given default options
      end
    end

    context "with ambiguous_month_year: :as_month" do
      before do
        Emendate.config.options.ambiguous_month_year = :as_month
        Emendate.config.options.max_month_number_handling = :edtf_level_1
      end

      it "returns season" do
        expect(type).to eq(:season)
        expect(lexeme).to eq("21")
        expect(literal).to eq(21)
        expect(warnings).to eq(
          "Ambiguous year + month/season/year treated as_season"
        )
      end
    end
  end
end
