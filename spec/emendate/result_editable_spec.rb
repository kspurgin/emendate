# frozen_string_literal: true

require "spec_helper"

class Editable
  include Emendate::ResultEditable

  attr_reader :result

  def initialize(tokens)
    @result = tokens
  end
end

RSpec.describe Emendate::ResultEditable do
  describe "#collapse_segments_backward" do
    it "collapses as expected" do
      tokens = Emendate.prepped_for(
        string: "Oct.? 31, 2021",
        target: Emendate::TokenCollapser
      )
      e = Editable.new(tokens)
      e.collapse_segments_backward(%i[month_alpha question space])
      # rubocop:todo Layout/LineLength
      expect(e.result.type_string).to eq("month_alpha number1or2 comma space number4")
      # rubocop:enable Layout/LineLength
      derived = e.result.segments.first
      expect(derived.lexeme).to eq("Oct.? ")
      expect(derived.literal).to eq(10)
    end
  end

  describe "#collapse_token_pair_backward" do
    it "collapses as expected" do
      tokens = Emendate.prepped_for(
        string: "Jan 2021",
        target: Emendate::TokenCollapser
      )
      e = Editable.new(tokens)
      e.collapse_token_pair_backward(tokens[0], tokens[1])
      expect(e.result.type_string).to eq("month_alpha number4")
      der = e.result[0]
      expect(der.literal).to eq(1)
      expect(der.lexeme).to eq("Jan ")
    end
  end

  describe "#collapse_token_pair_forward" do
    it "collapses as expected" do
      tokens = Emendate.prepped_for(
        string: ".1994",
        target: Emendate::TokenCollapser
      )
      e = Editable.new(tokens)
      e.collapse_token_pair_forward(tokens[0], tokens[1])
      expect(e.result.type_string).to eq("number4")
    end
  end

  describe "#replace_segtypes_with_new_type" do
    it "tags as expected" do
      tokens = Emendate.prepped_for(
        string: "2011 (?)",
        target: Emendate::TokenCollapser
      )
      e = Editable.new(tokens)
      segment_types = %i[parenthesis_open question parenthesis_close]
      e.replace_segtypes_with_new_type(
        old: segment_types, new: :question
      )
      expect(e.result.type_string).to eq("number4 space question")

      expect(e.result.extract(%i[question]).segments.first.sources.types).to eq(
        segment_types
      )
    end
  end

  describe "#replace_x_with_new" do
    it "tags as expected" do
      tokens = Emendate.prepped_for(
        string: "Jan 2021",
        target: Emendate::AlphaMonthConverter
      )
      e = Editable.new(tokens)
      e.replace_x_with_new(x: tokens[0], new: tokens[1])
      expect(e.result.type_string).to eq("number4 number4")
    end
  end

  describe "#collapse_first_token" do
    let(:string) { "[Jan. 21]" }

    it "tags as expected" do
      tokens = Emendate.prepped_for(
        string: string,
        target: Emendate::InferredDateHandler
      )
      e = Editable.new(tokens)
      e.collapse_first_token
      expect(e.result.type_string).to eq(
        "month number1or2 square_bracket_close"
      )
      expect(e.result.lexeme).to eq(string)
    end
  end

  describe "#collapse_last_token" do
    let(:string) { "[Jan. 21]" }

    it "tags as expected" do
      tokens = Emendate.prepped_for(
        string: string,
        target: Emendate::InferredDateHandler
      )
      e = Editable.new(tokens)
      e.collapse_last_token
      expect(e.result.type_string).to eq("square_bracket_open month number1or2")
      expect(e.result.lexeme).to eq(string)
    end
  end

  describe "#collapse_enclosing_tokens" do
    let(:string) { "[Jan. 21]" }

    it "tags as expected" do
      tokens = Emendate.prepped_for(
        string: string,
        target: Emendate::InferredDateHandler
      )
      e = Editable.new(tokens)
      e.collapse_enclosing_tokens
      expect(e.result.type_string).to eq("month number1or2")
      expect(e.result.lexeme).to eq(string)
    end
  end
end
