# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::DateTypes::YearMonthDay do
  subject { described_class.new(**params) }

  let(:tokens) do
    Emendate.prepped_for(string: string, target: Emendate::DateSegmenter)
  end
  let(:year) { 1987 }
  let(:month) { 4 }
  let(:day) { 13 }
  let(:params) { {year: year, month: month, day: day, sources: tokens} }

  context "when valid date" do
    let(:string) { "87-4-13" }

    it "creates expected datetype" do
      expect(subject.type).to eq(:yearmonthday_date_type)
      expect(subject.earliest).to eq(Date.new(1987, 4, 13))
      expect(subject.lexeme).to eq(string)
      expect(subject.literal).to eq(19870413)
      expect(subject.range?).to be_falsey
    end
  end

  context "when invalid date" do
    let(:string) { "1844 Jun 31" }
    let(:year) { 1844 }
    let(:month) { 6 }
    let(:day) { 31 }

    it "raises error" do
      expect { subject }.to raise_error(Emendate::InvalidDateError)
    end
  end

  context "when full leftward qualified" do
    let(:string) { "1987-04-13~" }

    it "handles qualifiers as expected" do
      expect(subject.approximate_qualifiers[0].precision).to eq(:whole)
    end
  end

  context "when month leftward qualified" do
    let(:string) { "1987-04~-13" }

    it "handles qualifiers as expected" do
      expect(subject.approximate_qualifiers[0].precision).to eq(:year_month)
    end
  end

  context "when month single-segment qualified" do
    let(:string) { "1987-~04-13" }

    it "handles qualifiers as expected" do
      expect(subject.approximate_qualifiers[0].precision).to eq(:month)
    end
  end

  context "when month rightward qualified" do
    let(:string) { "1987, around April 13" }

    it "handles qualifiers as expected" do
      expect(subject.approximate_qualifiers[0].precision).to eq(:month_day)
    end
  end

  context "when year qualified" do
    let(:string) { "1987~-04-13" }

    it "handles qualifiers as expected" do
      expect(subject.approximate_qualifiers[0].precision).to eq(:year)
    end
  end
end
