# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::DateTypes::Error do
  subject { described_class.new(sources: sources, error_type: type) }

  context "when unprocessable" do
    let(:type) { :unprocessable }
    let(:sources) do
      pf = prepped_for(
        string: "Y-20987654",
        target: Emendate::UnprocessableTagger
      )
    end

    it "returns as expected" do
      expect(subject.type).to eq(:unprocessable_date_type)
      expect(subject.lexeme).to eq("Y-20987654")
      expect(subject.literal).to be_nil
      expect(subject.date_part?).to be true
      expect(subject.date_type?).to be true
      expect(subject.earliest).to be_nil
      expect(subject.earliest_at_granularity).to be_nil
      expect(subject.latest).to be_nil
      expect(subject.latest_at_granularity).to be_nil
      expect(subject.range?).to be false
    end
  end

  context "when untokenizable" do
    let(:type) { :untokenizable }
    let(:sources) do
      pf = prepped_for(
        string: "Not a date",
        target: Emendate::UntokenizableTagger
      )
    end

    it "returns as expected" do
      expect(subject.type).to eq(:untokenizable_date_type)
      expect(subject.lexeme).to eq("Not a date")
      expect(subject.literal).to be_nil
      expect(subject.date_part?).to be true
      expect(subject.date_type?).to be true
      expect(subject.earliest).to be_nil
      expect(subject.latest).to be_nil
      expect(subject.range?).to be false
      expect(subject.earliest_at_granularity).to be_nil
      expect(subject.latest_at_granularity).to be_nil
    end
  end
end
