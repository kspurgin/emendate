require 'spec_helper'

RSpec.describe Emendate::DateTypes::YearMonth do
  before(:all) do
    @dt = Emendate::DateTypes::YearMonth.new(year: '2020', month: 2)
  end

  it 'type = :yearmonth_date_type' do
    expect(@dt.type).to eq(:yearmonth_date_type)
  end
  
  describe '#earliest' do
    it 'returns 2020-02-01' do
      expect(@dt.earliest).to eq(Date.new(2020, 2, 1))
    end
  end

  describe '#latest' do
    it 'returns 2020-02-29' do
      expect(@dt.latest).to eq(Date.new(2020, 2, 29))
    end
  end

  describe '#lexeme' do
    it 'returns 2020-02' do
      expect(@dt.lexeme).to eq('2020-02')
    end
  end
end
