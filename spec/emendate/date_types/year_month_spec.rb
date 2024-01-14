# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::DateTypes::YearMonth do
  let(:subject) { described_class.new(**args) }

  context "with `Feb. 2020`" do
    let(:tokens) do
      [
        Emendate::Segment.new(type: :month, lexeme: "Feb. ", literal: 2),
        Emendate::Number.new(type: :number, lexeme: "2020")
      ]
    end
    let(:args) { {month: 2, year: 2020, sources: tokens} }

    it "returns as expected" do
      expect(subject.type).to eq(:yearmonth_date_type)
      expect(subject.earliest).to eq(Date.new(2020, 2, 1))
      expect(subject.latest).to eq(Date.new(2020, 2, 29))
      expect(subject.lexeme).to eq("Feb. 2020")
      expect(subject.literal).to eq(202002)
    end
  end
end
