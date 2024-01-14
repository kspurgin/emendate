# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::DateTypes::Decade do
  subject { described_class.new(**args) }

  let(:tokens) do
    Emendate.prepped_for(string: str, target: Emendate::DateSegmenter)
  end
  let(:args) { {sources: tokens} }

  context "when plural decade" do
    let(:str) { "1990s" }

    it "returns expected values" do
      expect(subject.decade_type).to eq(:plural)
      expect(subject.earliest).to eq(Date.new(1990, 1, 1))
      expect(subject.latest).to eq(Date.new(1999, 12, 31))
      expect(subject.lexeme).to eq(str)
      expect(subject.literal).to eq(199)
    end
  end

  context "when plural and possibly century" do
    let(:str) { "1900s" }

    it "returns expected values" do
      expect(subject.earliest).to eq(Date.new(1900, 1, 1))
      expect(subject.latest).to eq(Date.new(1909, 12, 31))
      expect(subject.lexeme).to eq("1900s")
      expect(subject.literal).to eq(190)
    end
  end

  context "when plural and possibly millennium" do
    let(:str) { "2000s" }

    it "returns expected values" do
      expect(subject.earliest).to eq(Date.new(2000, 1, 1))
      expect(subject.latest).to eq(Date.new(2009, 12, 31))
      expect(subject.lexeme).to eq("2000s")
      expect(subject.literal).to eq(200)
    end
  end

  context "when plural and possibly century with 3 digits" do
    let(:str) { "200s" }

    it "returns expected values" do
      expect(subject.earliest).to eq(Date.new(200, 1, 1))
      expect(subject.latest).to eq(Date.new(209, 12, 31))
      expect(subject.lexeme).to eq("200s")
      expect(subject.literal).to eq(20)
    end
  end

  context "when uncertainty digit decade" do
    let(:str) { "199u" }

    it "returns expected values" do
      expect(subject.decade_type).to eq(:uncertainty_digits)
      expect(subject.earliest).to eq(Date.new(1990, 1, 1))
      expect(subject.latest).to eq(Date.new(1999, 12, 31))
      expect(subject.lexeme).to eq(str)
      expect(subject.literal).to eq(199)
    end
  end

  context "with partial indicator" do
    let(:str) { "1990s" }

    it "returns expected values for early" do
      t = Emendate::Segment.new(type: :partial, literal: :early,
        lexeme: "early ")
      subject.prepend_source_token(t)
      expect(subject.earliest).to eq(Date.new(1990, 1, 1))
      expect(subject.latest).to eq(Date.new(1993, 12, 31))
    end

    it "returns expected values for mid" do
      t = Emendate::Segment.new(type: :partial, literal: :mid,
        lexeme: "mid ")
      subject.prepend_source_token(t)
      expect(subject.earliest).to eq(Date.new(1994, 1, 1))
      expect(subject.latest).to eq(Date.new(1996, 12, 31))
    end

    it "returns expected values for late" do
      t = Emendate::Segment.new(type: :partial, literal: :late,
        lexeme: "late ")
      subject.prepend_source_token(t)
      expect(subject.earliest).to eq(Date.new(1997, 1, 1))
      expect(subject.latest).to eq(Date.new(1999, 12, 31))
    end
  end
end
