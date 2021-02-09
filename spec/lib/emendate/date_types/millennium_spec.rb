require 'spec_helper'

RSpec.describe Emendate::DateTypes::Millennium do
  context 'called without millennium_type' do
    it 'raises error' do
      expect{ Emendate::DateTypes::Millennium.new(millennium: 1000) }.to raise_error(Emendate::DateTypes::MissingMillenniumTypeError)
    end
  end

  context 'called with unsupported millennium_type value' do
    it 'raises error' do
      expect{ Emendate::DateTypes::Millennium.new(millennium: 0000, millennium_type: :misc) }.to raise_error(Emendate::DateTypes::MillenniumTypeValueError)
    end
  end
  
  context 'plural millennium (2000s)' do
    before(:all) do
      @dt = Emendate::DateTypes::Millennium.new(millennium: 2000, millennium_type: :plural)
    end
    
    describe '#earliest' do
      it 'returns 2000-01-01' do
        expect(@dt.earliest).to eq(Date.new(2000, 1, 1))
      end
    end

    describe '#latest' do
      it 'returns 2999-12-31' do
        expect(@dt.latest).to eq(Date.new(2999, 12, 31))
      end
    end

    describe '#lexeme' do
      it 'returns 2000s' do
        expect(@dt.lexeme).to eq('2000s')
      end
    end
  end

  context 'uncertainty_digit millennium (1XXX)' do
    before(:all) do
      @dt = Emendate::DateTypes::Millennium.new(millennium: 1, millennium_type: :uncertainty_digits)
    end
    
    describe '#earliest' do
      it 'returns 1000-01-01' do
        expect(@dt.earliest).to eq(Date.new(1000, 1, 1))
      end
    end

    describe '#latest' do
      it 'returns 1999-12-31' do
        expect(@dt.latest).to eq(Date.new(1999, 12, 31))
      end
    end

    describe '#lexeme' do
      it 'returns 1XXX' do
        expect(@dt.lexeme).to eq('1XXX')
      end
    end
  end
end
