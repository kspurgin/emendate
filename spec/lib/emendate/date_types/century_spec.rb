require 'spec_helper'

RSpec.describe Emendate::DateTypes::Century do
  context 'called without century_type' do
    it 'raises error' do
      expect{ Emendate::DateTypes::Century.new(century: 19) }.to raise_error(Emendate::DateTypes::MissingCenturyTypeError)
    end
  end

  context 'called with unsupported century_type value' do
    it 'raises error' do
      expect{ Emendate::DateTypes::Century.new(century: 19, century_type: :misc) }.to raise_error(Emendate::DateTypes::CenturyTypeValueError)
    end
  end
  
  context 'textual century name (19th)' do
    before(:all) do
      @dt = Emendate::DateTypes::Century.new(century: 19, century_type: :name)
    end

    it 'type = :century_date_type' do
      expect(@dt.type).to eq(:century_date_type)
    end
    
    describe '#earliest' do
      it 'returns 1801-01-01' do
        expect(@dt.earliest).to eq(Date.new(1801, 1, 1))
      end
    end

    describe '#latest' do
      it 'returns 1900-12-31' do
        expect(@dt.latest).to eq(Date.new(1900, 12, 31))
      end
    end

    describe '#lexeme' do
      it 'returns 19 century' do
        expect(@dt.lexeme).to eq('19 century')
      end
    end
  end

  context 'plural century (1900s)' do
    before(:all) do
      @dt = Emendate::DateTypes::Century.new(century: 19, century_type: :plural)
    end
    
    describe '#earliest' do
      it 'returns 1900-01-01' do
        expect(@dt.earliest).to eq(Date.new(1900, 1, 1))
      end
    end

    describe '#latest' do
      it 'returns 1999-12-31' do
        expect(@dt.latest).to eq(Date.new(1999, 12, 31))
      end
    end

    describe '#lexeme' do
      it 'returns 1900s' do
        expect(@dt.lexeme).to eq('1900s')
      end
    end
  end

  context 'uncertainty_digit century (19uu)' do
    before(:all) do
      @dt = Emendate::DateTypes::Century.new(century: 19, century_type: :uncertainty_digits)
    end
    
    describe '#earliest' do
      it 'returns 1900-01-01' do
        expect(@dt.earliest).to eq(Date.new(1900, 1, 1))
      end
    end

    describe '#latest' do
      it 'returns 1999-12-31' do
        expect(@dt.latest).to eq(Date.new(1999, 12, 31))
      end
    end

    describe '#lexeme' do
      it 'returns 19uu' do
        expect(@dt.lexeme).to eq('19uu')
      end
    end
  end
end
