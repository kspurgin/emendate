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
    context 'before' do
      it 'returns nil' do
        yr = Emendate::DateTypes::Year.new(year: '2021', range_switch: 'before')
        expect(yr.earliest).to be nil
      end
    end
    context 'after' do
      it 'returns 2022-01-01' do
        yr = Emendate::DateTypes::Year.new(year: '2021', range_switch: 'after')
        expect(yr.earliest).to eq(Date.new(2022, 1, 1))
      end
    end
    context 'after early' do
      it 'returns 2021-05-01' do
        yr = Emendate::DateTypes::Year.new(year: '2021', partial_indicator: 'early', range_switch: 'after')
        expect(yr.earliest).to eq(Date.new(2021, 5, 1))
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
    context 'before' do
      it 'returns 2020-12-31' do
        yr = Emendate::DateTypes::Year.new(year: '2021', range_switch: 'before')
        expect(yr.latest).to eq(Date.new(2020, 12, 31))
      end
    end
    context 'after' do
      it 'returns current date' do
        yr = Emendate::DateTypes::Year.new(year: '2021', range_switch: 'after')
        expect(yr.latest).to eq(Date.today)
      end
    end
    context 'before mid' do
      it 'returns 2021-07-31' do
        yr = Emendate::DateTypes::Year.new(year: '2021', partial_indicator: 'mid', range_switch: 'before')
        expect(yr.latest).to eq(Date.new(2021, 4, 30))
      end
    end
  end

  describe '#range?' do
    context 'no partial_indicator or range_switch' do
      it 'returns false' do
        expect(@yr.range?).to be false
      end
    end
    context 'partial_indicator' do
      it 'returns true' do
        yr = Emendate::DateTypes::Year.new(year: '2021', partial_indicator: 'early')
        expect(yr.range?).to be true
      end
    end
    context 'range_switch' do
      it 'returns true' do
        yr = Emendate::DateTypes::Year.new(year: '2021', range_switch: 'before')
        expect(yr.range?).to be true
      end
    end
    context 'partial_indicator and range_switch' do
      it 'returns true' do
        yr = Emendate::DateTypes::Year.new(year: '2021', partial_indicator: 'early', range_switch: 'before')
        expect(yr.range?).to be true
      end
    end
  end

  describe '#lexeme' do
    it 'returns 2021' do
      expect(@yr.lexeme).to eq('2021')
    end
  end
end
