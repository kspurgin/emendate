# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Emendate::DateTypes::DateType do
  before(:all) do
    @dt = described_class.new(literal: '2021')
  end

  it 'type = :datetype_date_type' do
    expect(@dt.type).to eq(:datetype_date_type)
  end

  describe '#date_part?' do
    it 'returns true' do
      expect(@dt.date_part?).to be true
    end
  end

  describe '#earliest' do
    it 'raise error' do
      expect{ @dt.earliest }.to raise_error(NotImplementedError)
    end
  end

  describe '#latest' do
    it 'raise error' do
      expect{ @dt.latest }.to raise_error(NotImplementedError)
    end
  end

  describe '#lexeme' do
    it 'raise error' do
      expect{ @dt.lexeme }.to raise_error(NotImplementedError)
    end
  end

  describe '#range?' do
    it 'raise error' do
      expect{ @dt.range? }.to raise_error(NotImplementedError)
    end
  end
end
