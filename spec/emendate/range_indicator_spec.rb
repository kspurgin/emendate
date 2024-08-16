# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::RangeIndicator do
  subject(:step) { described_class.call(tokens).value! }

  let(:tokens) { prepped_for(string: str, target: described_class) }

  let(:type_string) { subject.type_string }

  context "without range present (circa 202127)" do
    let(:str) { "circa 202127" }

    it "returns original" do
      expect(type_string).to eq("year_date_type")
      expect(subject.lexeme).to eq(str)
    end
  end

  context "with range present (1972 - 1999)" do
    let(:str) { "1972 - 1999" }

    it "returns range_date_type" do
      expect(type_string).to eq("range_date_type")
      expect(subject.lexeme).to eq(str)
    end
  end

  context "with ####-## -? (unknown end)" do
    let(:str) { "1922-03 -?" }

    it "segments as expected" do
      expect(type_string).to eq("range_date_type")
      expect(subject.lexeme).to eq(str)
    end
  end

  context "with ca. ####-####/####" do
    let(:str) { "ca. 1885-1895/1970" }
    it "returns range_date_type" do
      expect(type_string).to eq("range_date_type")
      expect(subject.lexeme).to eq(str)
    end
  end

  context "with mixed range and non-range (1970, 1972 - 1999, 2002)" do
    let(:str) { "1970, 1972 - 1999, 2002" }

    it "returns range_date_type" do
      expect(type_string).to eq("year_date_type date_separator "\
                                "range_date_type date_separator "\
                                "year_date_type")
      expect(subject.lexeme).to eq(str)
    end
  end

  context "with invalid range present (1999 - 1972)" do
    let(:str) { "1999 - 1972" }

    it "returns range_date_type" do
      expect(type_string).to eq("range_date_type")
      expect(subject.warnings.length).to eq(1)
      expect(subject.lexeme).to eq(str)
    end
  end

  context "with ####-<####>, ©####-<c####> and copyright treatment" do
    before { Emendate.config.options.c_before_date = :copyright }

    let(:str) { "1982-<1983>, ©1981-<c1982>" }

    it "segments as expected" do
      expect(subject.lexeme).to eq(str)
      expect(type_string).to eq(
        "range_date_type date_separator range_date_type"
      )
    end
  end

  context "with `1930s or 1940s`" do
    let(:str) { "1930s or 1940s" }

    it "returns multiple decade date types by default" do
      expect(type_string).to eq(
        "decade_date_type date_separator decade_date_type"
      )
      expect(subject.lexeme).to eq(str)
      expect(subject.warnings).to be_empty
    end

    context "with `and_or_date_handling: :single_range`" do
      before do
        Emendate.config.options.and_or_date_handling = :single_range
      end

      it "returns range_date_type" do
        expect(type_string).to eq("range_date_type")
        expect(subject.lexeme).to eq(str)
        expect(subject.warnings).to be_empty
      end
    end
  end

  context "with `1930s & 1940s`" do
    let(:str) { "1930s & 1940s" }

    it "returns multiple decade date types by default" do
      expect(type_string).to eq(
        "decade_date_type date_separator decade_date_type"
      )
      expect(subject.lexeme).to eq(str)
      expect(subject.warnings).to be_empty
    end

    context "with `and_or_date_handling: :single_range`" do
      before do
        Emendate.config.options.and_or_date_handling = :single_range
      end

      it "returns range_date_type" do
        expect(subject.lexeme).to eq(str)
        expect(type_string).to eq("range_date_type")
        expect(subject.warnings).to be_empty
      end
    end
  end

  context "with `1932-1942 or 1948-1949`" do
    let(:str) { "1932-1942 or 1948-1949" }

    it "returns multiple decade date types by default" do
      expect(type_string).to eq(
        "range_date_type date_separator range_date_type"
      )
      expect(subject.lexeme).to eq(str)
      expect(subject.warnings).to be_empty
    end

    context "with `and_or_date_handling: :single_range`" do
      before do
        Emendate.config.options.and_or_date_handling = :single_range
      end

      it "returns range_date_type" do
        expect(type_string).to eq("range_date_type")
        expect(subject.lexeme).to eq(str)
        expect(subject.warnings).to be_empty
      end
    end
  end
end
