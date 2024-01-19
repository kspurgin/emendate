# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::UnstructuredCertaintyHandler do
  subject { described_class.call(tokens).value! }

  before do
    Emendate.config.options.square_bracket_interpretation = :inferred_date
  end

  let(:tokens) { prepped_for(string: string, target: described_class) }

  context "with c. 2002" do
    let(:string) { "c. 2002" }

    it "handles as expected" do
      expect(subject.type_string).to eq("number4")
      expect(subject.lexeme).to eq(string)

      qual = subject[0].qualifiers.first
      expect(qual.type).to eq(:approximate)
      expect(qual.lexeme).to eq("circa")
      expect(qual.precision).to eq(:beginning)
    end
  end

  context "with 1920 ca" do
    let(:string) { "1920 ca" }

    it "handles as expected" do
      expect(subject.type_string).to eq("number4")
      expect(subject.lexeme).to eq(string)

      qual = subject[0].qualifiers.first
      expect(qual.type).to eq(:approximate)
      expect(qual.lexeme).to eq("circa")
      expect(qual.precision).to eq(:end)
    end
  end

  context "with 2020, possibly March" do
    let(:string) { "2020, possibly March" }

    it "handles as expected" do
      expect(subject.lexeme).to eq(string)
      expect(subject.type_string).to eq("number4 comma month")

      qual = subject[2].qualifiers.first
      expect(qual.type).to eq(:uncertain)
      expect(qual.lexeme).to eq("possibly")
      expect(qual.precision).to eq(:rightward)
    end
  end

  context "with probably c. 2002" do
    let(:string) { "probably c. 2002" }

    it "handles as expected" do
      expect(subject.lexeme).to eq(string)
      expect(subject.type_string).to eq("number4")

      quals = subject[0].qualifiers
      expect(quals.map(&:type)).to eq(%i[uncertain approximate])
      expect(quals.map(&:lexeme)).to eq(["probably", "circa"])
      expect(quals.map(&:precision)).to eq(%i[beginning beginning])
    end
  end

  context "with circa 2002?" do
    let(:string) { "circa 2002?" }

    it "handles as expected" do
      expect(subject.lexeme).to eq(string)
      expect(subject.type_string).to eq("number4")

      quals = subject[0].qualifiers
      expect(quals.map(&:type)).to eq(%i[uncertain approximate])
      expect(quals.map(&:lexeme)).to eq(["", "circa"])
      expect(quals.map(&:precision)).to eq(%i[end beginning])
    end
  end

  context "with [1997 or 1999]", skip: "move to separate set handling after "\
    "date segmentation" do
    let(:string) { "[1997 or 1999]" }

    it "has expected lexeme" do
      expect(subject.lexeme).to eq(string)
      expect(subject.certainty.sort).to eq(%i[inferred one_of_set])
      expected = "number4 date_separator number4"
      expect(subject.type_string).to eq(expected)
    end

    context "with `and_or_date_handling: :single_range`" do
      before do
        Emendate.config.options.and_or_date_handling = :single_range
      end

      it "has expected lexeme" do
        expect(subject.lexeme).to eq(string)
        expect(subject.certainty.sort).to eq(%i[inferred])
        expected = "number4 date_separator number4"
        expect(subject.type_string).to eq(expected)
      end
    end
  end
end
