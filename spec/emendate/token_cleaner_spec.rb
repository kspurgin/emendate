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
end
