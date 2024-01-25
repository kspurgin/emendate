# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::DateTypes::YearMonth do
  let(:subject) { described_class.new(**args) }

  let(:tokens) do
    Emendate.prepped_for(
      string: string, target: Emendate::DateSegmenter
    )
  end
  let(:args) { {month: 2, year: 2020, sources: tokens} }
  let(:qlexemes) { subject.qualifiers.map(&:lexeme).join(" ") }
  let(:qprecisions) { subject.qualifiers.map(&:precision).join(" ") }

  context "with three date parts" do
    let(:string) { "2020-02-23" }

    it "raises error" do
      expect { subject }.to raise_error(Emendate::DateTypeCreationError)
    end
  end

  context "with Feb. 2020" do
    let(:string) { "Feb. 2020" }

    it "returns as expected" do
      expect(subject.type).to eq(:yearmonth_date_type)
      expect(subject.earliest).to eq(Date.new(2020, 2, 1))
      expect(subject.latest).to eq(Date.new(2020, 2, 29))
      expect(subject.lexeme).to eq("Feb. 2020")
      expect(subject.literal).to eq(202002)
    end
  end

  context "with before Feb. 2020" do
    let(:string) { "before Feb. 2020" }

    context "when before date treated as range" do
      before do
        Emendate.config.options.before_date_treatment = :range
        Emendate.config.options.open_unknown_start_date = "1600-02-15"
      end

      it "returns as expected" do
        expect(subject.type).to eq(:yearmonth_date_type)
        expect(subject.earliest).to eq(Date.new(1600, 2, 15))
        expect(subject.latest).to eq(Date.new(2020, 1, 31))
        expect(subject.lexeme).to eq(string)
      end
    end

    context "when before date treated as point" do
      before do
        Emendate.config.options.before_date_treatment = :point
      end

      it "returns as expected" do
        expect(subject.latest).to eq(Date.new(2020, 1, 31))
        expect(subject.earliest).to eq(subject.latest)
      end
    end
  end

  context "with after Feb. 2020" do
    before { allow(Date).to receive(:today).and_return Date.new(2023, 6, 21) }
    let(:string) { "after Feb. 2020" }

    it "returns as expected" do
      expect(subject.earliest).to eq(Date.new(2020, 3, 1))
      expect(subject.latest).to eq(Date.new(2023, 6, 21))
    end
  end

  context "with mid Feb. 2020" do
    let(:string) { "mid Feb. 2020" }

    it "returns as expected" do
      expect(subject.earliest).to eq(Date.new(2020, 2, 11))
      expect(subject.latest).to eq(Date.new(2020, 2, 20))
    end
  end

  context "with [Feb. 2020]" do
    let(:string) { "[Feb. 2020]" }

    it "returns as expected" do
      expect(subject.inferred?).to be true
    end
  end

  context "with possibly 2020 February" do
    let(:string) { "possibly 2020 February" }

    it "returns as expected" do
      expect(subject.uncertain?).to be true
      expect(qlexemes).to eq("possibly")
    end
  end

  context "with 2020, possibly February" do
    let(:string) { "2020, possibly February" }

    it "returns as expected" do
      expect(subject.uncertain_qualifiers[0].precision).to eq(:month)
    end
  end

  context "with 2020, February, possibly" do
    let(:string) { "2020, February, possibly" }

    it "returns as expected" do
      expect(subject.uncertain?).to be true
      expect(qlexemes).to eq("possibly")
    end
  end

  context "with 2020-?02" do
    let(:string) { "2020-?02" }

    it "returns as expected" do
      expect(subject.uncertain?).to be true
      expect(qprecisions).to eq("month")
    end
  end
end
