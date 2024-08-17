# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::TokenCleaner do
  subject(:step) { described_class.call(tokens).value! }

  let(:tokens) { prepped_for(string: str, target: described_class) }

  let(:type_string) { subject.type_string }

  context "when no cleanup needed" do
    let(:str) { "circa 202127" }

    it "returns original tokens" do
      expect(type_string).to eq("year_date_type")
      expect(subject.lexeme).to eq(str)
    end
  end

  context "when date_separator present" do
    let(:str) { "1972 or 1975" }

    it "returns cleaned" do
      expect(type_string).to eq(
        "year_date_type year_date_type"
      )
      expect(subject.lexeme).to eq("1972 1975")
    end
  end

  context "when unknown segments present" do
    before do
      Emendate.config.options.final_check_failure_handling = :collapse_unhandled
    end

    let(:str) { "MDCCLXXIII [1773]" }

    it "returns cleaned" do
      expect(type_string).to eq(
        "year_date_type"
      )
      expect(subject.lexeme).to eq("[1773]")
    end
  end

  context "when collapsing unhandled segments" do
    before do
      Emendate.config.options.final_check_failure_handling = :collapse_unhandled
    end

    let(:str) { "1815-74 [v. 1]" }

    it "returns cleaned" do
      expect(type_string).to eq(
        "range_date_type"
      )
      expect(subject.lexeme).to eq("1815-74 ")
      expect(subject.orig_string).to eq(str)
      expect(subject.warnings.any? do |w|
               w.start_with?("Unhandled segments still present: ")
             end).to be true
    end
  end
end
