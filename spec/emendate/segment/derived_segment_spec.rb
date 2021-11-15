# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DerivedSegment do
  class Derivable < Emendate::DerivedToken
    include Emendate::DerivedSegment
  end

  describe '#derive' do
    context 'when one source' do
      before(:all) do
        orig_token = Emendate::Token.new(type: :sym, lexeme: 'str', literal: 1, location: :here)
        orig_token.add_certainty(:approximate)
        @derived = Derivable.new(type: :newtype, sources: [orig_token])
      end

      it 'derives values as expected' do
        r = "#{@derived.type} #{@derived.lexeme} #{@derived.literal} #{@derived.certainty.join} #{@derived.location}"
        e = 'newtype str 1 approximate here'
        expect(r).to eq(e)
      end
      
    end

    context 'when multiple sources' do
      before(:all) do
        t1 = Emendate::Token.new(type: :sym, lexeme: 'a ', literal: 1, location: Location.new(0, 2))
        t2 = Emendate::Token.new(type: :foo, lexeme: 'cat ', literal: 2, location: Location.new(2, 4))
        t3 = Emendate::Token.new(type: :bar, lexeme: 'sat', literal: 3, location: Location.new(6, 3))
        t1.add_certainty(:approximate)
        @derived = Derivable.new(type: :newtype, sources: [t1, t2, t3])
      end

      it 'derives lexeme from sources' do
        expect(@derived.lexeme).to eq('a cat sat')
      end

      it 'derives location from sources' do
        result = "#{@derived.location.col} #{@derived.location.length}"
        expect(result).to eq('0 9')
      end

      it 'derives numeric literal' do
        expect(@derived.literal).to eq(123)
      end
    end

    context 'when multiple sources' do
      before(:all) do
        t1 = Emendate::NumberToken.new(type: :number, lexeme: '1985', location: Location.new(0, 4))
        t2 = Emendate::Token.new(type: :single_dot, lexeme: '.', location: Location.new(4, 1))
        t3 = Emendate::NumberToken.new(type: :number, lexeme: '0', location: Location.new(5, 1))
        @derived = Derivable.new(type: t1.type, sources: [t1, t2, t3])
      end

      it 'derives lexeme from sources' do
        expect(@derived.lexeme).to eq('1985.0')
      end

      it 'derives location from sources' do
        result = "#{@derived.location.col} #{@derived.location.length}"
        expect(result).to eq('0 6')
      end

      it 'derives numeric literal' do
        expect(@derived.literal).to eq(1985)
      end
    end
  end
end
