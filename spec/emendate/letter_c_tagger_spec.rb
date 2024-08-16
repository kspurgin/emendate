# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::LetterCTagger do
  subject { described_class.call(tokens).value! }

  describe ".call" do
    let(:tokens) { prepped_for(string: string, target: described_class) }
    let(:result) { subject.types }

    context "with ####" do
      let(:string) { "1900" }

      it "passes value through" do
        expect(subject.lexeme).to eq(string)
        expect(subject).to eq(tokens)
      end
    end

    context "with possibly c. ####" do
      let(:string) { "possibly c. 2012" }

      context "when c_before_date = :circa" do
        before { Emendate.config.options.c_before_date = :circa }

        it "treats c as circa" do
          expect(subject.lexeme).to eq(string)
          expect(result).to eq(%i[number4])
          quals = subject[0].qualifiers
          expect(quals.map(&:type)).to eq(%i[uncertain approximate])
          expect(quals.map(&:lexeme)).to eq(%w[possibly circa])
        end
      end

      context "when c_before_date = :copyright" do
        before { Emendate.config.options.c_before_date = :copyright }

        it "treats c as copyright" do
          expect(subject.lexeme).to eq(string)
          expect(result).to eq(%i[number4])
          quals = subject[0].qualifiers
          expect(quals.map(&:type)).to eq(%i[uncertain])
          expect(quals.map(&:lexeme)).to eq(%w[possibly])
        end
      end
    end

    context "with -[c####]" do
      let(:string) { "-[c2012]" }

      context "when c_before_date = :circa" do
        before do
          Emendate.config.options.beginning_hyphen = :unknown
          Emendate.config.options.c_before_date = :circa
        end

        it "segments as expected" do
          expect(subject.lexeme).to eq(string)
          expect(result).to eq(
            %i[rangedatestartunknown_date_type range_indicator number4]
          )
          quals = subject[2].qualifiers
          expect(quals.map(&:type)).to include(:approximate)
          expect(quals.map(&:lexeme)).to include("circa")
        end
      end

      context "when c_before_date = :copyright" do
        before do
          Emendate.config.options.beginning_hyphen = :unknown
          Emendate.config.options.c_before_date = :copyright
        end

        it "segments as expected" do
          expect(subject.lexeme).to eq(string)
          expect(result).to eq(
            %i[rangedatestartunknown_date_type range_indicator number4]
          )
        end
      end
    end

    context "with ####-<####>, ©####-<c####> and copyright treatment" do
      before { Emendate.config.options.c_before_date = :copyright }

      let(:string) { "1982-<1983>, ©1981-<c1982>" }

      it "segments as expected" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(
          %i[number4 hyphen number4 comma number4 hyphen number4]
        )
      end
    end

    context "with ##ORD or ##ORD c." do
      let(:string) { "18th or 19th c." }

      it "segments as expected" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[number1or2 century or number1or2 century])
      end
    end
  end
end
