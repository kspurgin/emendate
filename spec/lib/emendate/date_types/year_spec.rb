require 'spec_helper'

RSpec.describe Emendate::DateTypes::Year do
  before(:all) do
    @yr = Emendate::DateTypes::Year.new(year: '2021')
  end

  it 'type = :year_date_type' do
    expect(@yr.type).to eq(:year_date_type)
  end
  
  describe '#earliest' do
    context 'no partial_indicator' do
      it 'returns Jan 1 of year' do
        expect(@yr.earliest).to eq(Date.new(2021, 1, 1))
      end
    end
    context 'early' do
      it 'returns Jan 1 of year' do
        yr = Emendate::DateTypes::Year.new(year: '2021', partial_indicator: 'early')
        expect(yr.earliest).to eq(Date.new(2021, 1, 1))
      end
    end
    context 'mid' do
      it 'returns May 1 of year' do
        yr = Emendate::DateTypes::Year.new(year: '2021', partial_indicator: 'mid')
        expect(yr.earliest).to eq(Date.new(2021, 5, 1))
      end
    end
    context 'late' do
      it 'returns Sep 1 of year' do
        yr = Emendate::DateTypes::Year.new(year: '2021', partial_indicator: 'late')
        expect(yr.earliest).to eq(Date.new(2021, 9, 1))
      end
    end
  end

  describe '#latest' do
    context 'no partial indicator' do
      it 'returns December 31 of year' do
        expect(@yr.latest).to eq(Date.new(2021, 12, 31))
      end
    end
    context 'early' do
      it 'returns Apr 30 of year' do
        yr = Emendate::DateTypes::Year.new(year: '2021', partial_indicator: 'early')
        expect(yr.latest).to eq(Date.new(2021, 4, 30))
      end
    end
    context 'mid' do
      it 'returns Aug 31 of year' do
        yr = Emendate::DateTypes::Year.new(year: '2021', partial_indicator: 'mid')
        expect(yr.latest).to eq(Date.new(2021, 8, 31))
      end
    end
    context 'late' do
      it 'returns Dec 31 of year' do
        yr = Emendate::DateTypes::Year.new(year: '2021', partial_indicator: 'late')
        expect(yr.latest).to eq(Date.new(2021, 12, 31))
      end
    end
  end

  describe '#lexeme' do
    it 'returns 2021' do
      expect(@yr.lexeme).to eq('2021')
    end
  end
end
