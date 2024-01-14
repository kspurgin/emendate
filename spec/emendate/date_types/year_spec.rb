# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::DateTypes::Year do
  subject(:yr) { described_class.new(**args) }

  let(:args) { {sources: tokens} }

  context "with `2021`" do
    let(:tokens) do
      [Emendate::Number.new(type: :number, lexeme: "2021")]
    end

    it "returns as expected" do
      expect(yr.type).to eq(:year_date_type)
      expect(yr.lexeme).to eq("2021")
      expect(yr.literal).to eq(2021)
      expect(yr.range?).to be_falsey
      expect(yr.earliest).to eq(Date.new(2021, 1, 1))
      expect(yr.earliest_at_granularity).to eq("2021")
      expect(yr.latest).to eq(Date.new(2021, 12, 31))
      expect(yr.latest_at_granularity).to eq("2021")
    end
  end

  context "with `early 2021`" do
    let(:tokens) do
      [
        Emendate::Token.new(type: :partial, lexeme: "early ", literal: :early),
        Emendate::Number.new(type: :number, lexeme: "2021")
      ]
    end

    it "returns as expected" do
      expect(yr.partial_indicator).to eq(:early)
      expect(yr.lexeme).to eq("early 2021")
      expect(yr.literal).to eq(2021)
      expect(yr.range?).to be true
      expect(yr.earliest).to eq(Date.new(2021, 1, 1))
      expect(yr.earliest_at_granularity).to eq("2021")
      expect(yr.latest).to eq(Date.new(2021, 4, 30))
      expect(yr.latest_at_granularity).to eq("2021")
    end
  end

  context "with `mid 2021`" do
    let(:tokens) do
      [
        Emendate::Token.new(type: :partial, lexeme: "mid ", literal: :mid),
        Emendate::Number.new(type: :number, lexeme: "2021")
      ]
    end

    it "returns as expected" do
      expect(yr.partial_indicator).to eq(:mid)
      expect(yr.lexeme).to eq("mid 2021")
      expect(yr.literal).to eq(2021)
      expect(yr.range?).to be true
      expect(yr.earliest).to eq(Date.new(2021, 5, 1))
      expect(yr.earliest_at_granularity).to eq("2021")
      expect(yr.latest).to eq(Date.new(2021, 8, 31))
      expect(yr.latest_at_granularity).to eq("2021")
    end
  end

  context "with `late 2021`" do
    let(:tokens) do
      [
        Emendate::Token.new(type: :partial, lexeme: "late ", literal: :late),
        Emendate::Number.new(type: :number, lexeme: "2021")
      ]
    end

    it "returns as expected" do
      expect(yr.partial_indicator).to eq(:late)
      expect(yr.lexeme).to eq("late 2021")
      expect(yr.literal).to eq(2021)
      expect(yr.range?).to be true
      expect(yr.earliest).to eq(Date.new(2021, 9, 1))
      expect(yr.earliest_at_granularity).to eq("2021")
      expect(yr.latest).to eq(Date.new(2021, 12, 31))
      expect(yr.latest_at_granularity).to eq("2021")
    end
  end

  context "with `before 2021`" do
    let(:tokens) do
      [
        Emendate::Token.new(type: :before, lexeme: "before "),
        Emendate::Number.new(type: :number, lexeme: "2021")
      ]
    end

    context "when `before_date_treatment: :point`" do
      before { Emendate.config.options.before_date_treatment = :point }

      it "returns as expected" do
        expect(yr.range_switch).to eq(:before)
        expect(yr.lexeme).to eq("before 2021")
        expect(yr.literal).to eq(2021)
        expect(yr.range?).to be false
        expect(yr.earliest).to eq(Date.new(2020, 12, 31))
        expect(yr.earliest_at_granularity).to eq("2020")
        expect(yr.latest).to eq(Date.new(2020, 12, 31))
        expect(yr.latest_at_granularity).to eq("2020")
      end
    end

    context "when `before_date_treatment: :range`" do
      before { Emendate.config.options.before_date_treatment = :range }

      it "returns as expected" do
        expect(yr.range?).to be true
        expect(yr.earliest).to eq(Date.new(1583, 1, 1))
        expect(yr.earliest_at_granularity).to eq("1583")
        expect(yr.latest).to eq(Date.new(2020, 12, 31))
        expect(yr.latest_at_granularity).to eq("2020")
      end
    end
  end

  context "with `231`" do
    let(:tokens) do
      [
        Emendate::Number.new(type: :number, lexeme: "231")
      ]
    end

    it "returns expected" do
      expect(yr.lexeme).to eq("231")
      expect(yr.literal).to eq(231)
      expect(yr.range?).to be_falsey
      expect(yr.earliest).to eq(Date.new(231, 1, 1))
      expect(yr.earliest_at_granularity).to eq("0231")
      expect(yr.latest).to eq(Date.new(231, 12, 31))
      expect(yr.latest_at_granularity).to eq("0231")
    end

    context "with bce set" do
      let(:bce) { Emendate::Token.new(type: :era_bce, lexeme: "BCE") }

      context "and with precise handling" do
        before { Emendate.config.options.bce_handling = :precise }

        it "returns expected" do
          yr.prepend_source_token(bce)
          expect(yr.lexeme).to eq("BCE231")
          expect(yr.literal).to eq(-230)
          expect(yr.range?).to be_falsey
          expect(yr.earliest).to eq(Date.new(-230, 1, 1))
          expect(yr.earliest_at_granularity).to eq("-0230")
          expect(yr.latest).to eq(Date.new(-230, 12, 31))
          expect(yr.latest_at_granularity).to eq("-0230")
        end
      end

      context "and with naive bce_handling" do
        before { Emendate.config.options.bce_handling = :naive }

        it "returns expected" do
          yr.append_source_token(bce)
          expect(yr.lexeme).to eq("231BCE")
          expect(yr.literal).to eq(-231)
          expect(yr.range?).to be_falsey
          expect(yr.earliest).to eq(Date.new(-231, 1, 1))
          expect(yr.earliest_at_granularity).to eq("-0231")
          expect(yr.latest).to eq(Date.new(-231, 12, 31))
          expect(yr.latest_at_granularity).to eq("-0231")
        end
      end
    end
  end

  context "with `after 2021`" do
    before { allow(Date).to receive(:today).and_return Date.new(2023, 6, 21) }

    let(:tokens) do
      [
        Emendate::Token.new(type: :after, lexeme: "after "),
        Emendate::Number.new(type: :number, lexeme: "2021")
      ]
    end

    it "returns as expected" do
      expect(yr.earliest).to eq(Date.new(2022, 1, 1))
      expect(yr.latest).to eq(Date.new(2023, 6, 21))
    end
  end

  context "with `after early 2021`" do
    before { allow(Date).to receive(:today).and_return Date.new(2023, 6, 21) }

    let(:tokens) do
      [
        Emendate::Token.new(type: :after, lexeme: "after "),
        Emendate::Token.new(type: :partial, lexeme: "early ", literal: :early),
        Emendate::Number.new(type: :number, lexeme: "2021")
      ]
    end

    it "returns as expected" do
      expect(yr.earliest).to eq(Date.new(2021, 5, 1))
      expect(yr.latest).to eq(Date.new(2023, 6, 21))
    end
  end

  context "with `before mid 2021`" do
    before { allow(Date).to receive(:today).and_return Date.new(2023, 6, 21) }

    let(:tokens) do
      [
        Emendate::Token.new(type: :before, lexeme: "before "),
        Emendate::Token.new(type: :partial, lexeme: "mid ", literal: :mid),
        Emendate::Number.new(type: :number, lexeme: "2021")
      ]
    end

    context "when before_date_treatment = :point" do
      before { Emendate.config.options.before_date_treatment = :point }

      it "returns as expected" do
        expect(yr.earliest).to eq(Date.new(2021, 4, 30))
        expect(yr.latest).to eq(Date.new(2021, 4, 30))
        expect(yr.range?).to be_falsey
      end
    end

    context "when before_date_treatment = :range" do
      before do
        Emendate.config.options.before_date_treatment = :range
      end

      it "returns as expected" do
        expect(yr.earliest).to eq(Emendate.options.open_unknown_start_date)
        expect(yr.latest).to eq(Date.new(2021, 4, 30))
        expect(yr.range?).to be true
      end
    end
  end
end
