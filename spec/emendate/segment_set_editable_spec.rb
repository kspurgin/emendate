# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::SegmentSetEditable do
  let(:target) { Emendate::TokenCollapser }
  let(:segset) do
    Emendate.prepped_for(string: string, target: target)
  end

  describe "#collapse_segments_backward" do
    let(:string) { "Oct.? 31, 2021" }

    it "collapses as expected" do
      segset.collapse_segments_backward(%i[month question space])
      expect(segset.type_string).to eq("month number1or2 comma space number4")
      derived = segset.segments.first
      expect(derived.lexeme).to eq("Oct.? ")
      expect(derived.literal).to eq(10)
    end
  end

  describe "#collapse_token_pair_backward" do
    let(:string) { "Jan 2021" }

    it "collapses as expected" do
      segset.collapse_token_pair_backward(segset[0], segset[1])
      expect(segset.type_string).to eq("month number4")
      derived = segset[0]
      expect(derived.literal).to eq(1)
      expect(derived.lexeme).to eq("Jan ")
    end
  end

  describe "#collapse_token_pair_forward" do
    let(:string) { ".1994" }

    it "collapses as expected" do
      segset.collapse_token_pair_forward(segset[0], segset[1])
      expect(segset.type_string).to eq("number4")
    end
  end

  describe "#replace_segtypes_with_new_type" do
    let(:string) { "2011 (?)" }

    it "tags as expected" do
      segment_types = %i[parenthesis_open question parenthesis_close]
      segset.replace_segtypes_with_new_type(old: segment_types, new: :question)
      expect(segset.type_string).to eq("number4 space question")

      expect(segset.extract(%i[question]).segments.first.sources.types).to eq(
        segment_types
      )
    end
  end

  describe "#replace_x_with_new" do
    let(:string) { "Jan 2021" }

    it "tags as expected" do
      segset.replace_x_with_new(x: segset[0], new: segset[2])
      expect(segset.type_string).to eq("number4 space number4")
    end
  end

  describe "#collapse_first_token" do
    let(:string) { "[Jan. 21]" }
    let(:target) { Emendate::BracketPairHandler }

    it "tags as expected" do
      segset.collapse_first_token
      expect(segset.type_string).to eq(
        "month number1or2 square_bracket_close"
      )
      expect(segset.lexeme).to eq(string)
    end
  end

  describe "#collapse_last_token" do
    let(:string) { "[Jan. 21]" }
    let(:target) { Emendate::BracketPairHandler }

    it "tags as expected" do
      segset.collapse_last_token
      expect(segset.type_string).to eq("square_bracket_open month number1or2")
      expect(segset.lexeme).to eq(string)
    end
  end

  describe "#collapse_enclosing_tokens" do
    let(:string) { "[Jan. 21]" }
    let(:target) { Emendate::BracketPairHandler }

    it "tags as expected" do
      segset.collapse_enclosing_tokens
      expect(segset.type_string).to eq("month number1or2")
      expect(segset.lexeme).to eq(string)
    end
  end
end
