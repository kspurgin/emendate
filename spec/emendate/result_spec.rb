# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::Result do
  subject(:klass) { described_class.new(pm) }

  let(:pm) { Emendate.process(str) }

  describe "#dates" do
    let(:result) { klass.dates }

    context "with date having unhandled segments (1815-74 [v. 1, 1874])" do
      let(:str) { "1815-74 [v. 1, 1874]" }

      context "with final_check_failure_handling: :collapse_unhandled" do
        before do
          Emendate.config.options.final_check_failure_handling =
            :collapse_unhandled
        end

        it "returns as expected" do
          expect(result.length).to eq(2)
          expect(klass.warnings.length).to eq(1)
        end
      end

      context "with final_check_failure_handling: "\
        ":collapse_unhandled_first_date" do
        before do
          Emendate.config.options.final_check_failure_handling =
            :collapse_unhandled_first_date
        end

        it "returns as expected" do
          expect(result.length).to eq(1)
          expect(klass.warnings.length).to eq(2)
        end
      end
    end
  end

  describe "#to_h" do
    let(:result) { klass.to_h }
    let(:str) { "mid 1800s to 2/23/1921" }

    it "returns hash" do
      expect(result[:original_string]).to eq(str)
      keys = %i[original_string dates errors warnings].sort
      expect(result.keys.sort).to eq(keys)
      expect(result[:warnings].length).to eq(1)
      expect(result[:dates].length).to eq(1)
      expect(result[:errors].length).to eq(0)
    end
  end
end
