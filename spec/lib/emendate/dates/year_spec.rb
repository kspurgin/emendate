require 'spec_helper'

RSpec.describe Emendate::DateTypes::Year do
  before(:all) do
    @yr = Emendate::DateTypes::Year.new(year: '2021')
  end

  it 'type = :year_date_type' do
    expect(@yr.type).to eq(:year_date_type)
  end
  
  describe '#earliest' do
    it 'returns Jan 1 of year' do
      expect(@yr.earliest).to eq(Date.new(2021, 1, 1))
    end
  end

  describe '#latest' do
    it 'returns December 31 of year' do
      expect(@yr.latest).to eq(Date.new(2021, 12, 31))
    end
  end

  describe '#lexeme' do
    it 'returns 2021' do
      expect(@yr.lexeme).to eq('2021')
    end
  end
end
