# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::Segment do
  subject { described_class.new(**args) }

  context "with sources" do
    let(:args) { {type: derived_type, sources: sources} }
    let(:derived_type) { :newtype }

    context "when one source" do
      let(:sources) do
        orig_token = Emendate::Segment.new(type: :sym, lexeme: "str",
          literal: 1)
        orig_token.add_qualifier(
          Emendate::Qualifier.new(type: :approximate, precision: :whole)
        )
        [orig_token]
      end

      it "derives values as expected" do
        expect(subject.type).to eq(:newtype)
        expect(subject.lexeme).to eq("str")
        expect(subject.literal).to eq(1)
        expect(subject.qualifiers.map(&:type)).to eq([:approximate])
      end
    end

    context "when multiple sources" do
      context "when all sources have numeric literals" do
        let(:sources) do
          t1 = Emendate::Segment.new(type: :sym, lexeme: "a ", literal: 1)
          t1.add_qualifier(
            Emendate::Qualifier.new(type: :approximate, precision: :whole)
          )
          t2 = Emendate::Segment.new(type: :foo, lexeme: "cat ", literal: 2)
          t2.add_qualifier(
            Emendate::Qualifier.new(type: :uncertain, precision: :whole)
          )
          t3 = Emendate::Segment.new(type: :bar, lexeme: "sat", literal: 3)
          [t1, t2, t3]
        end

        it "derives values as expected" do
          expect(subject.type).to eq(:newtype)
          expect(subject.lexeme).to eq("a cat sat")
          expect(subject.literal).to eq(123)
          expect(subject.qualifiers.map(&:type)).to eq(
            [:approximate, :uncertain]
          )
        end
      end

      context "when sources have numeric and nil literals (1985.0)" do
        let(:sources) do
          [
            Emendate::Number.new(lexeme: "1985"),
            Emendate::Segment.new(type: :single_dot, lexeme: "."),
            Emendate::Number.new(lexeme: "0")
          ]
        end
        let(:derived_type) { :number4 }

        it "derives values as expected" do
          expect(subject.type).to eq(:number4)
          expect(subject.lexeme).to eq("1985.0")
          expect(subject.literal).to eq(1985)
        end
      end

      context "one source has symbol literal (mid )" do
        let(:sources) do
          [
            Emendate::Segment.new(type: :partial, lexeme: "mid", literal: :mid),
            Emendate::Segment.new(type: :space, lexeme: " ", literal: nil)
          ]
        end
        let(:derived_type) { :partial }

        it "derives values as expected" do
          expect(subject.type).to eq(:partial)
          expect(subject.lexeme).to eq("mid ")
          expect(subject.literal).to eq(:mid)
        end
      end

      context "no sources have numeric or symbol literals (, )" do
        let(:sources) do
          [
            Emendate::Segment.new(type: :comma, lexeme: ","),
            Emendate::Segment.new(type: :space, lexeme: " ")
          ]
        end
        let(:derived_type) { :comma }

        it "derives values as expected" do
          expect(subject.type).to eq(:comma)
          expect(subject.lexeme).to eq(", ")
          expect(subject.literal).to be_nil
        end
      end

      context "with mixed Integer and Symbol literals" do
        let(:sources) do
          [
            Emendate::Segment.new(type: :partial, lexeme: "mid", literal: :mid),
            Emendate::Number.new(lexeme: "1985")
          ]
        end

        it "raises error" do
          expect { subject }.to raise_error(Emendate::DerivedSegmentError,
            /Cannot derive literal from mixed Integers and Symbols/)
        end
      end

      context "with multiple Symbol literals" do
        let(:sources) do
          [
            Emendate::Segment.new(type: :partial, lexeme: "mid", literal: :mid),
            Emendate::Segment.new(type: :partial, lexeme: "mid", literal: :mid)
          ]
        end

        it "raises error" do
          expect { subject }.to raise_error(Emendate::DerivedSegmentError,
            /Cannot derive literal from multiple symbols/)
        end
      end

      context "with unexpected literal pattern" do
        let(:sources) do
          [
            Emendate::Segment.new(type: :partial, lexeme: "mid", literal: :mid),
            Emendate::Segment.new(type: :string, lexeme: "mid",
              literal: "string")
          ]
        end

        it "raises error" do
          expect { subject }.to raise_error(Emendate::DerivedSegmentError,
            /Cannot derive literal for unknown reason/)
        end
      end

      context "with multiple levels of derivation" do
        let(:segset) do
          Emendate.prepped_for(
            string: "[c. 2020-03]", target: Emendate::FormatStandardizer
          )
        end

        it "sets sources and subsources as expected" do
          seg = segset[0]
          expect(seg.type).to eq(:letter_c)
          expect(seg.sources.types).to eq(%i[square_bracket_open letter_c])
          expect(seg.subsources.types).to eq(%i[square_bracket_open letter_c
            single_dot space])
        end
      end
    end
  end
end
