# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DateTypes::Range do
  subject(:range){ described_class.new(sources: tokens) }

  let(:tokens) do
    Emendate.prepped_for(
      string: str,
      target: Emendate::RangeIndicator
      )
  end

  context 'with 1900 to 1985' do
    let(:str){ '1900 to 1985' }

    it 'earliest = 1900-01-01' do
      expect(range.earliest).to eq(Date.new(1900, 1, 1))
    end

    it 'latest = 1985-12-31' do
      expect(range.latest).to eq(Date.new(1985, 12, 31))
    end

    it 'lexeme = 1900-01-01 - 1985-12-31' do
      expect(range.lexeme).to eq('1900-01-01 - 1985-12-31')
    end
  end
end
