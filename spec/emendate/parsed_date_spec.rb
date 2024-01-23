# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::ParsedDate do
  subject(:parsed) { described_class.new(**args) }

  let(:pos) { 0 }
  let(:args) do
    pm = Emendate.process(str, options)
    dateparts = pm.tokens.segments.select { |t| t.date_type? }
    {date: dateparts[pos], orig: pm.orig_string}
  end

  let(:options) { {} }

  describe "#new" do
    context "with non-date type passed in" do
      let(:args) do
        token = Emendate::Segment.new(type: :foo)
        {date: token, orig: "token"}
      end

      it "raises error" do
        expect { parsed }.to raise_error(Emendate::NonDateTypeError)
      end
    end
  end

  describe "#original_string" do
    let(:result) { parsed.original_string }

    context "with `mid 1800s to 2/23/1921`" do
      let(:str) { "mid 1800s to 2/23/1921" }

      it "returns expected" do
        expect(result).to eq(str)
      end
    end
  end

  describe "#to_h" do
    let(:result) { parsed.to_h }

    context "with 2/23/2021" do
      let(:str) { "2/23/2021" }

      let(:expected) do
        {original_string: "2/23/2021",
         date_start: nil,
         date_end: nil,
         date_start_full: "2021-02-23",
         date_end_full: "2021-02-23",
         inclusive_range: false,
         qualifiers: [],
         range_switch: nil,
         era: nil}
      end

      it "returns as expected" do
        expect(result).to eq(expected)
      end
    end
  end
end
