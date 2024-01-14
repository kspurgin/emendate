# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::ShortYearHandler do
  subject { described_class }

  let(:str) { "21" }
  let(:token) do
    Emendate::Segment.new(type: :stub, lexeme: str, literal: str.to_i)
  end
  let(:result) { subject.call(token) }

  context "with two_digit_year_handling: :coerce and ambiguous year: 21" do
    before do
      Emendate.config.options.two_digit_year_handling = :coerce
      # It's always the year 2401
      allow(Date).to receive(:today).and_return Date.new(2401, 2, 3)
    end

    context "when value > threshold" do
      before do
        Emendate.config.options.ambiguous_year_rollback_threshold = 15
      end

      it "coerced to previous century" do
        expect(result.literal).to eq(2321)
        expect(result.lexeme).to eq("21")
      end
    end

    context "when value = threshold" do
      before do
        Emendate.config.options.ambiguous_year_rollback_threshold = 21
      end

      it "coerced to previous century" do
        expect(result.literal).to eq(2321)
      end
    end

    context "when value < threshold" do
      before do
        Emendate.config.options.ambiguous_year_rollback_threshold = 50
      end

      it "coerced to current century" do
        expect(result.literal).to eq(2421)
      end
    end
  end

  context "when two_digit_year_handling: :literal" do
    before do
      Emendate.config.options.two_digit_year_handling = :literal
    end

    context "with ambiguous year: 21" do
      it "left as 21" do
        expect(result.literal).to eq(21)
        expect(result.lexeme).to eq("21")
      end
    end
  end
end
