# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::BracketPairHandler do
  subject { described_class.call(tokens) }

  before do
    Emendate.config.options.square_bracket_interpretation = :inferred_date
    Emendate.config.options.angle_bracket_interpretation = :temporary
  end

  let(:tokens) { prepped_for(string: string, target: described_class) }
  let(:result) { subject.value! }
  let(:wholequal) do
    result.qualifiers
      .select { |q| q.precision == :whole }
  end

  context "with no brackets" do
    let(:string) { "circa 2002?" }

    it "passes result through unchanged" do
      expect(result.lexeme).to eq(string)
      expect(result.type_string).to eq(tokens.type_string)
    end
  end

  context "with non-matching square bracket inside matching pair" do
    let(:string) { "[1997-[1998]" }

    context "when mismatched_bracket_handling == :absorb" do
      before { Emendate.config.options.mismatched_bracket_handling = :absorb }

      it "absorbs non-matching bracket" do
        expect(result.lexeme).to eq(string)
        expect(result.lexeme).to eq(string)
        expect(result.type_string).to eq("number4 hyphen number4")
        expect(result[0].qualifiers.first.type).to eq(:inferred)
        expect(result[1].qualifiers.first.type).to eq(:inferred)
        expect(result[2].qualifiers.first.type).to eq(:inferred)
        expect(wholequal).to be_empty
      end
    end

    context "when mismatched_bracket_handling == :failure" do
      before { Emendate.config.options.mismatched_bracket_handling = :failure }

      it "fails" do
        expect(subject).to be_a(Dry::Monads::Failure)
      end
    end
  end

  context "with non-matching angle bracket inside matching square bracket "\
    "pair" do
    let(:string) { "[1997-<1998]" }

    context "when mismatched_bracket_handling == :absorb" do
      before { Emendate.config.options.mismatched_bracket_handling = :absorb }

      it "absorbs non-matching bracket" do
        expect(result.lexeme).to eq(string)
        expect(result.lexeme).to eq(string)
        expect(result.type_string).to eq("number4 hyphen number4")
        expect(result[0].qualifiers).to be_empty
        expect(result[1].qualifiers).to be_empty
        expect(result[2].qualifiers).to be_empty
        expect(wholequal.length).to eq(1)
      end
    end

    context "when mismatched_bracket_handling == :failure" do
      before { Emendate.config.options.mismatched_bracket_handling = :failure }

      it "fails" do
        expect(subject).to be_a(Dry::Monads::Failure)
      end
    end
  end

  context "with non-matching open square bracket" do
    let(:string) { "[1997]-[1998" }

    context "when mismatched_bracket_handling == :absorb" do
      before { Emendate.config.options.mismatched_bracket_handling = :absorb }

      it "absorbs non-matching bracket" do
        expect(result.lexeme).to eq(string)
        expect(result.type_string).to eq("number4 hyphen number4")
        expect(result[0].qualifiers.first.type).to eq(:inferred)
        expect(result[2].qualifiers).to be_empty
      end
    end

    context "when mismatched_bracket_handling == :failure" do
      before { Emendate.config.options.mismatched_bracket_handling = :failure }

      it "fails" do
        expect(subject).to be_a(Dry::Monads::Failure)
      end
    end
  end

  context "with non-matching open angle bracket" do
    let(:string) { "<1997>-<1998" }

    context "when mismatched_bracket_handling == :absorb" do
      before { Emendate.config.options.mismatched_bracket_handling = :absorb }

      it "absorbs non-matching bracket" do
        expect(result.lexeme).to eq(string)
        expect(result.type_string).to eq("number4 hyphen number4")
        expect(result[0].qualifiers.first.type).to eq(:temporary)
        expect(result[2].qualifiers).to be_empty
      end
    end

    context "when mismatched_bracket_handling == :failure" do
      before { Emendate.config.options.mismatched_bracket_handling = :failure }

      it "fails" do
        expect(subject).to be_a(Dry::Monads::Failure)
      end
    end
  end

  context "with non-matching close square bracket" do
    let(:string) { "1997-1998]" }

    context "when mismatched_bracket_handling == :absorb" do
      before { Emendate.config.options.mismatched_bracket_handling = :absorb }

      it "absorbs non-matching bracket" do
        expect(result.lexeme).to eq(string)
        expect(result.type_string).to eq("number4 hyphen number4")
        expect(result[0].qualifiers).to be_empty
        expect(result[2].qualifiers).to be_empty
      end
    end

    context "when mismatched_bracket_handling == :failure" do
      before { Emendate.config.options.mismatched_bracket_handling = :failure }

      it "fails" do
        expect(subject).to be_a(Dry::Monads::Failure)
      end
    end
  end

  context "with non-matching close angle bracket" do
    let(:string) { "1997-1998>" }

    context "when mismatched_bracket_handling == :absorb" do
      before { Emendate.config.options.mismatched_bracket_handling = :absorb }

      it "absorbs non-matching bracket" do
        expect(result.lexeme).to eq(string)
        expect(result.type_string).to eq("number4 hyphen number4")
        expect(result[0].qualifiers).to be_empty
        expect(result[2].qualifiers).to be_empty
      end
    end

    context "when mismatched_bracket_handling == :failure" do
      before { Emendate.config.options.mismatched_bracket_handling = :failure }

      it "fails" do
        expect(subject).to be_a(Dry::Monads::Failure)
      end
    end
  end

  context "with [circa 2002?]" do
    let(:string) { "[circa 2002?]" }

    it "sets inferred qualifiers as expected" do
      expect(result.lexeme).to eq(string)
      expect(result.type_string).to eq("approximate number4 question")
      expect(wholequal.length).to eq(1)
    end
  end

  context "with <circa 2002?>" do
    let(:string) { "<circa 2002?>" }

    it "sets temporary qualifiers as expected" do
      expect(result.lexeme).to eq(string)
      expect(result.type_string).to eq("approximate number4 question")
      expect(wholequal.length).to eq(1)
    end
  end

  context "with [1997]-<1998>" do
    let(:string) { "[1997]-<1998>" }

    it "sets inferred qualifiers as expected" do
      expect(result.lexeme).to eq(string)
      expect(result.type_string).to eq("number4 hyphen number4")
      expect(result[0].qualifiers.first.type).to eq(:inferred)
      expect(result[2].qualifiers.first.type).to eq(:temporary)
    end
  end

  context "with [1997 or 1999]" do
    let(:string) { "[1997 or 1999]" }

    it "sets inferred qualifiers as expected" do
      expect(result.lexeme).to eq(string)
      expect(result.type_string).to eq("number4 or number4")
      expect(wholequal.length).to eq(1)
    end
  end
end
