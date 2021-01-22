require 'spec_helper'

RSpec.describe Emendate::NumberToken do
  before(:all) do
    @loc = Location.new(2, 5)
  end

  context 'allowed length' do
    before(:all) do
      @t = Emendate::NumberToken.new(type: :number, lexeme: '12', location: @loc)
    end
    it 'sets type as expected' do
      expect(@t.type).to eq(:number1or2)
    end
    it 'sets literal as expected' do
      expect(@t.literal).to eq(12)
    end
    it 'sets digits as expected' do
      expect(@t.digits).to eq(2)
    end
  end

  context 'disallowed length' do
    before(:all) do
      @t = Emendate::NumberToken.new(type: :number, lexeme: '55555', location: @loc)
    end
    it 'sets type as expected' do
      expect(@t.type).to eq(:unknown)
    end
    it 'sets literal as expected' do
      expect(@t.literal).to eq(55555)
    end
    it 'sets digits as expected' do
      expect(@t.digits).to eq(5)
    end
  end

  context 'created with non-number type' do
    it 'raises error' do
      expect{
        Emendate::NumberToken.new(type: :notnumber, lexeme: '1', location: @loc)
      }.to raise_error(Emendate::TokenTypeError)
    end
  end

  context 'created with non-number lexeme' do
    it 'raises error' do
      expect{
        Emendate::NumberToken.new(type: :number, lexeme: '1a', location: @loc)
      }.to raise_error(Emendate::TokenLexemeError)
    end
  end
end
