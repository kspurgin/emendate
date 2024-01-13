# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::DateTypes::RangeDateUnknownOrOpen do
  subject { described_class.new(**args) }

  let(:str) { ".." }
  let(:tokens) do
    Emendate.prepped_for(string: str, target: Emendate::FormatStandardizer)
  end
  let(:baseargs) { {sources: tokens} }

  context "when category = :open and point = :start" do
    let(:args) { baseargs.merge({category: :open, point: :start}) }

    it "returns expected values" do
      expect(subject.type).to eq(:rangedatestartopen_date_type)
      expect(subject.earliest).to eq(Date.new(1583, 1, 1))
      expect(subject.earliest_at_granularity).to be_nil
      expect(subject.latest).to be_nil
      expect(subject.latest_at_granularity).to be_nil
      expect(subject.lexeme).to eq(str)
      expect(subject.literal).to eq(15830101)
      expect(subject.range?).to be false
    end

    context "with custom datevalue: 1900-01-01" do
      before do
        Emendate.config.options.open_unknown_start_date =
          "1900-01-01"
      end

      it "returns values for custom datevalue" do
        expect(subject.earliest).to eq(Date.new(1900, 1, 1))
      end
    end
  end

  context "when category = :open and point = :end" do
    let(:args) { baseargs.merge({category: :open, point: :end}) }

    it "returns expected values" do
      expect(subject.type).to eq(:rangedateendopen_date_type)
      expect(subject.earliest).to be_nil
      expect(subject.latest).to eq(Date.new(2999, 12, 31))
    end

    context "with custom datevalue: 2050-01-01" do
      before do
        Emendate.config.options.open_unknown_end_date =
          "2050-01-01"
      end

      it "returns values for custom datevalue" do
        expect(subject.latest).to eq(Date.new(2050, 1, 1))
      end
    end
  end

  context "when category = :unknown and point = :start" do
    let(:args) { baseargs.merge({category: :unknown, point: :start}) }

    it "returns expected values" do
      expect(subject.type).to eq(:rangedatestartunknown_date_type)
    end
  end

  context "when category = :unknown and point = :end" do
    let(:args) { baseargs.merge({category: :unknown, point: :end}) }

    it "returns expected values" do
      expect(subject.type).to eq(:rangedateendunknown_date_type)
    end
  end
end
