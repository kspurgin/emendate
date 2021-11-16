# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DateTypes::OpenRangeDate do
  let(:opts){ {} }
  let(:options){ Emendate::Options.new(opts) }
  let(:open){ Emendate::DateTypes::OpenRangeDate.new(use_date: options.open_unknown_start_date, usage: :start) }

  it 'type = :openrangedate_date_type' do
    expect(open.type).to eq(:openrangedate_date_type)
  end

  describe '#earliest' do
    it 'returns 0001-1-1' do
      expect(open.earliest).to eq(Date.new(1, 1, 1))
    end
  end

  describe '#latest' do
    it 'returns 0001-1-1' do
      expect(open.latest).to eq(Date.new(1, 1, 1))
    end
  end

  describe '#literal' do
    it 'returns 10101' do
      expect(open.literal).to eq(10101)
    end
  end

  describe '#range?' do
    it 'returns false' do
      expect(open.range?).to be false
    end
  end

  describe '#lexeme' do
    it 'returns open date' do
      expect(open.lexeme).to eq('open start date')
    end
  end
end
