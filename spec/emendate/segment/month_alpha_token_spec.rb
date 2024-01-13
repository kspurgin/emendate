# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::MonthAlphaToken do
  subject { described_class }

  let(:type) { :month_alpha }
  let(:loc) { "loc" }
  let(:t) do
    described_class.new(type: :month_alpha, lexeme: lexeme, location: loc)
  end

  describe "#.new" do
    let(:result) { subject.new(type: type, lexeme: lexeme, location: loc) }

    context "with September" do
      let(:lexeme) { "September" }

      it "sets literal as expected" do
        expect(result.literal).to eq(9)
      end
    end

    context "with Sept." do
      let(:lexeme) { "Sept." }

      it "sets literal as expected" do
        expect(result.literal).to eq(9)
      end
    end

    context "with Foo" do
      let(:lexeme) { "Foo" }

      it "raises error" do
        expect { result }.to raise_error(Emendate::MonthLiteralError)
      end
    end

    context "when created with non-month_alpha type" do
      let(:lexeme) { "Jan." }
      let(:type) { :notmonthalpha }

      it "raises error" do
        expect { result }.to raise_error(Emendate::TokenTypeError)
      end
    end
  end
end
