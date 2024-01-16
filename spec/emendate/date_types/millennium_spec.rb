# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::DateTypes::Millennium do
  subject { described_class.new(**args) }

  let(:tokens) do
    Emendate.prepped_for(string: str, target: Emendate::DateSegmenter)
  end
  let(:baseargs) { {sources: tokens} }
  let(:args) { baseargs }

  context "when :plural type" do
    before do
      Emendate.config.options.pluralized_date_interpretation = :broad
    end

    let(:str) { "2000s" }
    let(:args) { baseargs }

    it "returns expected values" do
      expect(subject.type).to eq(:millennium_date_type)
      expect(subject.millennium_type).to eq(:plural)
      expect(subject.lexeme).to eq(str)
      expect(subject.literal).to eq(2)
      expect(subject.earliest).to eq(Date.new(2000, 1, 1))
      expect(subject.latest).to eq(Date.new(2999, 12, 31))
      expect(subject.earliest_at_granularity).to eq(2000)
      expect(subject.latest_at_granularity).to eq(2999)
    end
  end

  context "when :uncertainty_digits type" do
    let(:str) { "2uuu" }
    let(:args) { baseargs }

    it "returns expected values" do
      expect(subject.type).to eq(:millennium_date_type)
      expect(subject.millennium_type).to eq(:uncertainty_digits)
      expect(subject.lexeme).to eq(str)
      expect(subject.literal).to eq(2)
      expect(subject.earliest).to eq(Date.new(2000, 1, 1))
      expect(subject.latest).to eq(Date.new(2999, 12, 31))
      expect(subject.earliest_at_granularity).to eq(2000)
      expect(subject.latest_at_granularity).to eq(2999)
    end
  end
end
