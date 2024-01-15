# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::SeasonAlpha do
  subject { described_class }

  let(:type) { :season }
  let(:t) do
    described_class.new(type: :season, lexeme: lexeme)
  end

  describe "#.new" do
    let(:result) { subject.new(type: type, lexeme: lexeme) }

    context "with Winter" do
      let(:lexeme) { "Winter" }

      it "sets literal as expected" do
        expect(result.literal).to eq(24)
      end
    end

    context "with Foo" do
      let(:lexeme) { "Foo" }

      it "raises error" do
        expect { result }.to raise_error(Emendate::SeasonLiteralError)
      end
    end

    context "when created with non-season type" do
      let(:lexeme) { "autumn" }
      let(:type) { :notseason }

      it "raises error" do
        expect { result }.to raise_error(Emendate::TokenTypeError)
      end
    end
  end
end
