# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::SegmentSetQueryable do
  let(:target) { Emendate::TokenCollapser }
  let(:string) { "Oct.? 21-31, 2021" }
  let(:segset) do
    Emendate.prepped_for(string: string, target: target)
  end

  describe "#consecutive_of_type" do
    let(:res) { segset.consecutive_of_type(type) }
    let(:type) { :question }

    context "when pattern present" do
      let(:string) { "April ????, approximately?" }
      let(:type) { :question }

      it "returns as expected" do
        expect(res).to be_a(Emendate::SegmentSet)
        expect(res.length).to eq(4)
      end
    end

    context "when type present but not consecutively" do
      let(:string) { "approximately April 1999?" }

      it "returns as expected" do
        expect(res).to be_a(Emendate::SegmentSet)
        expect(res).to be_empty
      end
    end
  end

  describe "#previous_segment" do
    context "with prior segments" do
      let(:seg) { segset.when_type(:number1or2).last }

      it "returns segment" do
        expect(segset.previous_segment(seg).type).to eq(:hyphen)
      end
    end

    context "with no prior segments" do
      let(:seg) { segset.when_type(:month).first }

      it "returns nil" do
        expect(segset.previous_segment(seg)).to be_nil
      end
    end
  end

  describe "#segments_before" do
    let(:res) { segset.segments_before(seg) }

    context "with prior segments" do
      let(:seg) { segset.when_type(:number1or2).last }

      it "returns segment set" do
        expect(res).to be_a(Emendate::SegmentSet)
        expect(res.length).to eq(5)
        expect(res.last.type).to eq(:hyphen)
      end
    end

    context "with no prior segments" do
      let(:seg) { segset.when_type(:month).first }

      it "returns empty segment set" do
        expect(res).to be_empty
      end
    end
  end

  describe "#next_segment" do
    context "with next segments" do
      let(:seg) { segset.when_type(:number1or2).last }

      it "returns segment" do
        expect(segset.next_segment(seg).type).to eq(:comma)
      end
    end

    context "with no next segments" do
      let(:seg) { segset.when_type(:number4).last }

      it "returns nil" do
        expect(segset.next_segment(seg)).to be_nil
      end
    end
  end

  describe "#segments_after" do
    let(:res) { segset.segments_after(seg) }

    context "with next segments" do
      let(:seg) { segset.when_type(:number1or2).last }

      it "returns segment set" do
        expect(res).to be_a(Emendate::SegmentSet)
        expect(res.length).to eq(3)
        expect(res.first.type).to eq(:comma)
        expect(res.last.type).to eq(:number4)
      end
    end

    context "with no next segments" do
      let(:seg) { segset.when_type(:number4).last }

      it "returns empty segment set" do
        expect(res).to be_empty
      end
    end
  end
end
