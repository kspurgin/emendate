
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::NumberToken do
  let(:loc){ Location.new(2, 5) }
  let(:t){ described_class.new(type: :number, lexeme: lexeme, location: loc) }

  context 'with an allowed length' do
    let(:lexeme){ '12' }
    it 'sets type as expected' do
      expect(t.type).to eq(:number1or2)
    end

    it 'sets literal as expected' do
      expect(t.literal).to eq(12)
    end

    it 'sets digits as expected' do
      expect(t.digits).to eq(2)
    end

    it 'sets location as expected' do
      expect(t.location).to eq(loc)
    end
  end

  context 'when zero' do
    let(:lexeme){ '0' }
    it 'sets type as expected' do
      expect(t.type).to eq(:standalone_zero)
    end

    it 'sets literal as expected' do
      expect(t.literal).to be nil
    end

    it 'sets digits as expected' do
      expect(t.digits).to eq(1)
    end

    it 'sets location as expected' do
      expect(t.location).to eq(loc)
    end
  end
  
  context 'with a disallowed length' do
    let(:lexeme){ '55555' }

    it 'sets type as expected' do
      expect(t.type).to eq(:unknown)
    end

    it 'sets literal as expected' do
      expect(t.literal).to eq(55555)
    end

    it 'sets digits as expected' do
      expect(t.digits).to eq(5)
    end

    it 'sets location as expected' do
      expect(t.location).to eq(loc)
    end
  end

  context 'when created with non-number type' do
    it 'raises error' do
      expect{
        described_class.new(type: :notnumber, lexeme: '1', location: loc)
      }.to raise_error(Emendate::TokenTypeError)
    end
  end

  context 'when created with non-number lexeme' do
    it 'raises error' do
      expect{
        described_class.new(type: :number, lexeme: '1a', location: loc)
      }.to raise_error(Emendate::TokenLexemeError)
    end
  end
end
