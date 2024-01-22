# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::SegmentSets::SegmentSet do
  subject(:set) { described_class }

  let(:segments) do
    %i[a b c d].map { |t| Emendate::Segment.new(type: t, lexeme: t.to_s) }
  end
  let(:string) { "str" }
  let(:segset) { set.new(string: string, segments: segments) }

  describe ".new" do
    context "with no args" do
      it "initializes as expected" do
        result = set.new
        expect(result.orig_string).to be_nil
        expect(result.segments).to be_empty
      end
    end

    context "with string arg" do
      it "initializes as expected" do
        result = set.new(string: string)
        expect(result.orig_string).to eq(string)
        expect(result.segments).to be_empty
      end
    end

    context "with segments" do
      it "initializes as expected" do
        result = set.new(segments: segments)
        expect(result.orig_string).to be_nil
        expect(result.segments.length).to eq(4)
      end
    end

    context "with string and segments" do
      it "initializes as expected" do
        result = set.new(string: string, segments: segments)
        expect(result.orig_string).to eq(string)
        expect(result.segments.length).to eq(4)
      end
    end
  end

  describe "#<<" do
    it "adds segment as expected" do
      segset << Emendate::Segment.new(type: :z, lexeme: "z")
      expect(segset.length).to eq(5)
      expect(segset.last.type).to eq(:z)
      expect(segset.lexeme).to eq("abcdz")
    end
  end

  describe "#unshift" do
    it "adds segment as expected" do
      segset.unshift(Emendate::Segment.new(type: :z, lexeme: "z"))
      expect(segset.length).to eq(5)
      expect(segset.first.type).to eq(:z)
      expect(segset.lexeme).to eq("zabcd")
    end
  end

  describe "#add_qualifier" do
    context "with Qualifier" do
      it "adds qualifier as expected" do
        segset
        expect(segset.qualifiers).to be_empty
        q = Emendate::Qualifier.new(type: :uncertain, precision: :whole)
        segset.add_qualifier(q)
        expect(segset.qualifiers.length).to eq(1)
      end
    end

    context "with non-Qualifier" do
      it "raises error" do
        segset
        expect(segset.qualifiers).to be_empty
        expect { segset.add_qualifier(:q) }.to raise_error(
          Emendate::QualifierTypeError
        )
      end
    end
  end

  describe "#copy" do
    it "copies as expected" do
      set.new.copy(segset)
      result = set.new(string: string, segments: segments)
      expect(result.orig_string).to eq(string)
      expect(result.segments.length).to eq(4)
    end
  end

  describe "#extract" do
    let(:result) { segset.extract(types) }

    context "when given subset" do
      let(:types) { %i[b c] }

      it "extracts subset" do
        expect(result).to be_a(set)
        expect(result.types).to eq(types)
      end
    end

    context "when given full match" do
      let(:types) { %i[a b c d] }

      it "returns copy of whole set" do
        expect(result.types).to eq(types)
      end
    end

    context "when given more types than in set" do
      let(:types) { %i[a b c d e] }

      it "returns empty set" do
        expect(result.types).to be_empty
      end
    end
  end

  describe "#extract_by_date_part" do
    let(:string) { "2000 Feb - April to 2010 March - June" }
    let(:segments) do
      Emendate.prepped_for(
        string: string,
        target: Emendate::FormatStandardizer
      ).segments
    end
    let(:result) { segset.extract_by_date_part(types) }

    context "when given subset" do
      let(:types) { %i[number4 month month] }

      it "extracts subset" do
        expect(result).to be_a(set)
        expect(result.types).to eq(%i[number4 month hyphen month])
      end
    end
  end

  describe "#map" do
    context "when results of mapping are kinds of Segments" do
      let(:result) { segset.map { |t| t.dup } }

      it "returns kind of SegmentSet" do
        expect(result).to be_a(described_class)
      end
    end

    context "when results of mapping are not kinds of Segments" do
      let(:result) { segset.map { |t| t.lexeme } }

      it "returns Array" do
        expect(result).to be_a(Array)
      end
    end
  end

  describe "#types" do
    let(:string) { "Feb. 3, 2000" }
    let(:segments) do
      Emendate.prepped_for(
        string: string,
        target: Emendate::DatePartTagger
      ).segments
    end
    let(:result) { segset.types }

    it "lists types" do
      expect(result).to eq(%i[month number1or2 number4])
    end
  end

  describe "#type_string" do
    let(:string) { "Feb. 3, 2000" }
    let(:segments) do
      Emendate.prepped_for(
        string: string,
        target: Emendate::DatePartTagger
      ).segments
    end
    let(:result) { segset.type_string }

    it "lists types" do
      expect(result).to eq("month number1or2 number4")
    end
  end

  describe "#source_types" do
    let(:string) { "Feb. 3, 2000" }
    let(:segments) do
      Emendate.prepped_for(
        string: string,
        target: Emendate::DatePartTagger
      ).segments
    end
    let(:result) { segset.source_types }

    it "lists types" do
      expect(result).to eq(%i[month space number1or2 comma number4])
    end
  end

  describe "#source_type_string" do
    let(:string) { "Feb. 3, 2000" }
    let(:segments) do
      Emendate.prepped_for(
        string: string,
        target: Emendate::DatePartTagger
      ).segments
    end
    let(:result) { segset.source_type_string }

    it "lists types" do
      expect(result).to eq("month space number1or2 comma number4")
    end
  end

  describe "#subsource_types" do
    let(:string) { "Feb. 3, 2000" }
    let(:segments) do
      Emendate.prepped_for(
        string: string,
        target: Emendate::DatePartTagger
      ).segments
    end
    let(:result) { segset.subsource_types }

    it "lists types" do
      expect(result).to eq(%i[month space number1or2 comma space number4])
    end
  end

  describe "#subsource_type_string" do
    let(:string) { "Feb. 3, 2000" }
    let(:segments) do
      Emendate.prepped_for(
        string: string,
        target: Emendate::DatePartTagger
      ).segments
    end
    let(:result) { segset.subsource_type_string }

    it "lists types" do
      expect(result).to eq("month space number1or2 comma space number4")
    end
  end
end
