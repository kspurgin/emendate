# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::DateTypes::Range do
  subject(:range) { described_class.new(sources: tokens) }

  let(:tokens) do
    Emendate.prepped_for(
      string: str,
      target: Emendate::RangeIndicator
    )
  end

  context "with 1900 to 1985" do
    let(:str) { "1900 to 1985" }

    it "returns as expected" do
      expect(range.earliest).to eq(Date.new(1900, 1, 1))
      expect(range.latest).to eq(Date.new(1985, 12, 31))
      expect(range.lexeme).to eq(str)
    end
  end

  context "with 1922-3" do
    let(:str) { "1922-3" }

    it "returns as expected" do
      expect(range.earliest).to eq(Date.new(1922, 1, 1))
      expect(range.latest).to eq(Date.new(1923, 12, 31))
      expect(range.lexeme).to eq(str)
    end
  end

  context "with 1922-? (unknown end)" do
    let(:str) { "1922-?" }

    it "returns as expected" do
      expect(range.earliest).to eq(Date.new(1922, 1, 1))
      expect(range.latest).to eq(Date.new(2999, 12, 31))
      expect(range.lexeme).to eq(str)
    end

    context "with custom unknown end range" do
      before(:context) do
        Emendate.config.options.open_unknown_end_date = "2050-01-01"
      end

      after(:context) { Emendate.reset_config }

      it "returns as expected" do
        expect(range.earliest).to eq(Date.new(1922, 1, 1))
        expect(range.latest).to eq(Date.new(2050, 1, 1))
        expect(range.lexeme).to eq(str)
      end
    end
  end
end
