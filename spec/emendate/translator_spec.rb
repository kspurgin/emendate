# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::Translator do
  subject(:translator) { described_class.new(pm) }

  before { Emendate.config.options.dialect = :edtf }
  let(:pm) { Emendate.process(str) }

  context "with multiple parsed dates for string" do
    let(:str) { "1906, 1920, 1929" }

    context "with max_output_dates = :all" do
      before { Emendate.config.options.max_output_dates = :all }

      it "translates all dates" do
        expect(translator.call.values.length).to eq(3)
      end
    end

    context "with max_output_dates = 1" do
      before { Emendate.config.options.max_output_dates = 1 }

      it "translates all dates" do
        expect(translator.call.values.length).to eq(1)
        expect(translator.call.warnings).to include(
          "3 dates parsed from string. Only 1 date(s) translated"
        )
      end
    end
  end
end
