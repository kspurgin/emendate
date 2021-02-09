require 'spec_helper'

RSpec.describe Emendate::DateTypes::Decade do
  context 'called without decade_type' do
    it 'raises error' do
      expect{ Emendate::DateTypes::Decade.new(decade: 199) }.to raise_error(Emendate::DateTypes::MissingDecadeTypeError)
    end
  end

  context 'called with unsupported decade_type value' do
    it 'raises error' do
      expect{ Emendate::DateTypes::Decade.new(decade: 199, decade_type: :misc) }.to raise_error(Emendate::DateTypes::DecadeTypeValueError)
    end
  end
  
  context 'plural decade (1990s)' do
    before(:all) do
      @dt = Emendate::DateTypes::Decade.new(decade: 1999, decade_type: :plural)
    end
    
    describe '#earliest' do
      it 'returns 1990-01-01' do
        expect(@dt.earliest).to eq(Date.new(1990, 1, 1))
      end
    end

    describe '#latest' do
      it 'returns 1999-12-31' do
        expect(@dt.latest).to eq(Date.new(1999, 12, 31))
      end
    end

    describe '#lexeme' do
      it 'returns 1990s' do
        expect(@dt.lexeme).to eq('1990s')
      end
    end
  end

  context 'uncertainty_digit decade (199u)' do
    before(:all) do
      @dt = Emendate::DateTypes::Decade.new(decade: 199, decade_type: :uncertainty_digits)
    end
    
    describe '#earliest' do
      it 'returns 1990-01-01' do
        expect(@dt.earliest).to eq(Date.new(1990, 1, 1))
      end
    end

    describe '#latest' do
      it 'returns 1999-12-31' do
        expect(@dt.latest).to eq(Date.new(1999, 12, 31))
      end
    end

    describe '#lexeme' do
      it 'returns 199X' do
        expect(@dt.lexeme).to eq('199X')
      end
    end
  end
end
