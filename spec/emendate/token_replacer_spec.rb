# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::TokenReplacer do
  subject { described_class.call(tokens).value! }

  describe ".call" do
    let(:tokens) { prepped_for(string: string, target: described_class) }
    let(:result) { subject.type_string }

    context "with possibly about 1990" do
      let(:string) { "possibly about 1990" }

      it "replaces about token with derived approximate" do
        expect(result).to eq("uncertain space approximate space number4")
        expect(subject.lexeme).to eq(string)
      end
    end
  end
end
