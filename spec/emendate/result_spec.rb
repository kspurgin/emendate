# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::Result do
  subject(:klass) { described_class.new(pm) }

  let(:pm) { Emendate.process(str) }

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
