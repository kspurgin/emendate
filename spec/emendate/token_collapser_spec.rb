# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::TokenCollapser do
  subject { described_class.call(tokens).value! }

  describe ".call" do
    let(:tokens) { prepped_for(string: string, target: described_class) }
    let(:result) { subject.types }

    context "with (C) ####" do
      let(:string) { "(C) 1947" }

      it "collapses as expected" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[number4])
      end
    end

    context "with ####, (c)####" do
      let(:string) { "1984, (c)1985" }

      it "collapses as expected" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[number4 comma number4])
      end
    end

    context "with ##-##-##" do
      let(:string) { "02-10-20" }

      it "collapses as expected" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[number1or2 number1or2 number1or2])
      end
    end

    context "with ##-MON-##" do
      let(:string) { "16-Mar-51" }

      it "collapses as expected" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[number1or2 month number1or2])
      end
    end

    context "with ##-##-####" do
      let(:string) { "02-10-2000" }

      it "collapses as expected" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[number1or2 number1or2 number4])
      end
    end

    context "with ####-##-## - ####-##-##" do
      let(:string) { "1974-11-23 - 1974-11-24" }

      it "collapses as expected" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[number4 number1or2 number1or2
          hyphen
          number4 number1or2 number1or2])
      end
    end

    context "with ####-## -? (unknown end)" do
      let(:string) { "1922-03 -?" }

      it "segments as expected" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[number4 number1or2 range_indicator
          unknown_date])
      end
    end

    context "with #### MONTH #-#### MON ##" do
      let(:string) { "2000 June 3-2001 Jan 20" }

      it "tags as expected" do
        expect(result).to eq(
          %i[number4 month number1or2 hyphen number4 month number1or2]
        )
        expect(subject.lexeme).to eq(string)
      end
    end

    context "with mid ####s / ##/##/####" do
      let(:string) { "mid 1800s / 2/23/1921" }

      it "removes slashes in second date, but keeps range indicating slash" do
        expect(result).to eq(%i[partial number4 letter_s slash
          number1or2 number1or2 number4])
        expect(subject.lexeme).to eq(string)
      end
    end

    context "with MON ##, #### - MONTH ##, ####" do
      let(:string) { "Feb. 15, 1999 - February 20, 2020" }

      it "removes commas after dates" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(
          %i[month number1or2 number4
            hyphen
            month number1or2 number4]
        )
      end
    end

    context "with MON ##, ####" do
      let(:string) { "Jan. 21, 2014" }

      it "collapses as expected" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[month number1or2 number4])
      end
    end

    context "with ####.#" do
      let(:string) { "2014.0" }

      it "drops `.0` at end" do
        expect(result).to eq([:number4])
        expect(subject.lexeme).to eq(string)
      end
    end

    context "with #/####" do
      let(:string) { "3/2020" }

      it "collapse slash into 3" do
        expect(result).to eq(%i[number1or2 number4])
        expect(subject.lexeme).to eq(string)
      end
    end

    context "with pre-####" do
      let(:string) { "pre-1750" }

      it "collapses - into pre" do
        expect(result).to eq(%i[before number4])
        expect(subject.lexeme).to eq(string)
      end
    end

    context "with mid-####" do
      let(:string) { "mid-1750" }

      it "collapses - into mid" do
        expect(result).to eq(%i[partial number4])
        expect(subject.lexeme).to eq(string)
      end
    end

    context "with ####'s" do
      let(:string) { %(1800's) }

      it "collapses apostrophe into s" do
        expect(result).to eq(%i[number4 letter_s])
        expect(subject.lexeme).to eq(string)
      end
    end

    context "with #### (?)" do
      let(:string) { "1985 (?)" }

      it "collapses (?) into ?" do
        expect(result).to eq(%i[number4 question])
        expect(subject.lexeme).to eq(string)
      end
    end

    context "with ####, MON ##" do
      let(:string) { "2020, Feb 15" }

      it "returns as expected" do
        expect(result).to eq(%i[number4 month number1or2])
        expect(subject.lexeme).to eq(string)
      end
    end

    context "with MON '##" do
      let(:string) { "Nov. '73" }

      it "collapses as expected" do
        expect(result).to eq(%i[month number1or2])
        expect(subject.lexeme).to eq(string)
      end
    end

    context "with ####, possibly MONTH" do
      let(:string) { "2020, possibly March" }

      it "collapses as expected" do
        expect(result).to eq(%i[number4 uncertain month])
        expect(subject.lexeme).to eq(string)
      end
    end
  end
end
