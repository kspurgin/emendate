# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::Options do
  subject(:opts) { described_class }
  after(:each) { Emendate.reset_config }

  context "when called with option hash" do
    let(:call_options) { described_class.new(opthash) }

    context "with valid setting" do
      let(:opthash) { {ambiguous_month_day: :as_day_month} }
      it "sets option" do
        call_options
        expect(Emendate.options.ambiguous_month_day).to eq(:as_day_month)
      end
    end

    context "with unknown option key" do
      let(:opthash) { {foo: :bar} }
      it "outputs message to STDOUT and exits" do
        expect { call_options }.to output(
          /:foo option is not allowed/
        ).to_stdout.and raise_error(SystemExit)
      end
    end

    context "with unknown value for option" do
      let(:opthash) { {ambiguous_month_day: :as_month} }
      it "outputs message to STDOUT and exits" do
        msg = ":ambiguous_month_day option :as_month is not an allowed "\
          "value. Use one of: :as_month_day, :as_day_month\nExiting...\n"
        expect { call_options }.to output(msg).to_stdout.and raise_error(
          SystemExit
        )
      end
    end

    context "with invalid date string for date option" do
      let(:opthash) { {open_unknown_end_date: "2023-02-30"} }
      it "outputs message to STDOUT and exits" do
        msg = ":open_unknown_end_date option value 2023-02-30 cannot be "\
          "parsed into a valid date. Use a date string in the format: "\
          "YYYY-MM-DD\nExiting...\n"
        expect { call_options }.to output(msg).to_stdout.and raise_error(
          SystemExit
        )
      end
    end

    context "with edtf: true" do
      let(:opthash) { {edtf: true} }
      it "sets other options as expected" do
        call_options
        expect(Emendate.options.beginning_hyphen).to eq(:edtf)
        expect(Emendate.options.ending_slash).to eq(:unknown)
        expect(Emendate.options.max_month_number_handling).to eq(:edtf_level_2)
        expect(Emendate.options.square_bracket_interpretation).to eq(:edtf_set)
      end
    end

    context "with dialect: :collectionspace" do
      let(:opthash) { {dialect: :collectionspace} }
      it "sets other options as expected" do
        call_options
        expect(Emendate.options.and_or_date_handling).to eq(:single_range)
        expect(Emendate.options.bce_handling).to eq(:naive)
        expect(Emendate.options.before_date_treatment).to eq(:point)
        expect(Emendate.options.max_output_dates).to eq(1)
      end
    end

    context "with open_unknown_start_date: '1600-02-15'" do
      let(:opthash) { {open_unknown_start_date: "1600-02-15"} }
      it "converts to date" do
        call_options
        expect(Emendate.options.open_unknown_start_date).to eq(Date.new(1600,
          2, 15))
      end
    end
  end
end
