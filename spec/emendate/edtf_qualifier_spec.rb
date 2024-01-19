# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::EdtfQualifier do
  subject { described_class.call(tokens).value! }

  describe ".call" do
    let(:tokens) { prepped_for(string: string, target: described_class) }

    context "with non-EDTF question mark" do
      let(:string) { "circa 2002?" }

      it "passes through" do
        expect(subject.types).to eq(tokens.types)
      end
    end

    context "with 2004-06~" do
      let(:string) { "2004-06~" }

      it "qualifies_as_expected" do
        expect(subject.lexeme).to eq(string)

        qual = subject[2].qualifiers.first
        expect(qual.type).to eq(:approximate)
        expect(qual.precision).to eq(:leftward)
      end
    end

    context "with 2004-06~-11" do
      let(:string) { "2004-06~-11" }

      it "qualifies_as_expected" do
        expect(subject.lexeme).to eq(string)
        expect(subject.type_string).to eq(
          "number4 hyphen number1or2 hyphen number1or2"
        )
        qual = subject[2].qualifiers.first
        expect(qual.type).to eq(:approximate)
        expect(qual.precision).to eq(:leftward)
      end
    end

    context "with ~2004-06-%11" do
      let(:string) { "~2004-06-%11" }

      it "qualifies as expected" do
        expect(subject.lexeme).to eq(string)
        expect(subject.type_string).to eq(
          "number4 hyphen number1or2 hyphen number1or2"
        )
        year_qual = subject[0].qualifiers.first
        expect(year_qual.type).to eq(:approximate)
        expect(year_qual.precision).to eq(:single_segment)

        day_qual = subject[4].qualifiers.first
        expect(day_qual.type).to eq(:approximate_and_uncertain)
        expect(day_qual.precision).to eq(:single_segment)
      end
    end
  end
end
