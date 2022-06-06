# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DerivedSegment do
  class Derivable < Emendate::Token
    include Emendate::DerivedSegment

    private

    def post_initialize(opts)
      derive(opts)
    end
  end

  let(:derived_type){ :newtype }
  let(:klass){ Derivable.new(type: derived_type, sources: sources) }
  

  describe '#derive' do
    context 'when one source' do
      let(:sources) do
        orig_token = Emendate::Token.new(type: :sym, lexeme: 'str', literal: 1, location: :here)
        orig_token.add_certainty(:approximate)
        [orig_token]
      end

      it 'derives values as expected' do
        expect(klass.type).to eq(:newtype)
        expect(klass.lexeme).to eq('str')
        expect(klass.literal).to eq(1)
        expect(klass.location).to eq(:here)
      end
    end

    context 'when multiple sources' do
      context 'when all sources have numeric literals' do
        let(:sources) do
          t1 = Emendate::Token.new(type: :sym, lexeme: 'a ', literal: 1, location: Emendate::Location.new(0, 2))
          t1.add_certainty(:approximate)
          t2 = Emendate::Token.new(type: :foo, lexeme: 'cat ', literal: 2, location: Emendate::Location.new(2, 4))
          t3 = Emendate::Token.new(type: :bar, lexeme: 'sat', literal: 3, location: Emendate::Location.new(6, 3))
          [t1, t2, t3]
        end

        it 'derives values as expected' do
          expect(klass.type).to eq(:newtype)
          expect(klass.lexeme).to eq('a cat sat')
          expect(klass.literal).to eq(123)
          expect(klass.location.col).to eq(0)
          expect(klass.location.length).to eq(9)
        end
      end

      context 'when some sources do not have numeric literals (1985.0)' do
        let(:sources) do
          [
            Emendate::NumberToken.new(type: :number, lexeme: '1985', location: Emendate::Location.new(0, 4)),
            Emendate::Token.new(type: :single_dot, lexeme: '.', location: Emendate::Location.new(4, 1)),
            Emendate::NumberToken.new(type: :number, lexeme: '0', location: Emendate::Location.new(5, 1))
          ]
        end
        let(:derived_type){ :number }

        it 'derives values as expected' do
          expect(klass.type).to eq(:number)
          expect(klass.lexeme).to eq('1985.0')
          expect(klass.literal).to eq(1985)
          expect(klass.location.col).to eq(0)
          expect(klass.location.length).to eq(6)
        end
      end

      context 'when some sources do not have numeric literals (2/)' do
        let(:sources) do
          [
            Emendate::NumberToken.new(type: :number, lexeme: '2', location: Emendate::Location.new(0, 1)),
            Emendate::Token.new(type: :hyphen, lexeme: '/', location: Emendate::Location.new(1, 1))
          ]
        end
        let(:derived_type){ :number }

        it 'derives values as expected' do
          expect(klass.type).to eq(:number)
          expect(klass.lexeme).to eq('2/')
          expect(klass.literal).to eq(2)
          expect(klass.location.col).to eq(0)
          expect(klass.location.length).to eq(2)
        end
      end

      context 'no sources have numeric literals (, )' do
        let(:sources) do
          [
            Emendate::Token.new(type: :comma, lexeme: ',', location: Emendate::Location.new(7, 1)),
            Emendate::Token.new(type: :space, lexeme: ' ', location: Emendate::Location.new(8, 1))
          ]
        end
        let(:derived_type){ :comma }

        it 'derives values as expected' do
          expect(klass.type).to eq(:comma)
          expect(klass.lexeme).to eq(',')
          expect(klass.literal).to be_nil
          expect(klass.location.col).to eq(7)
          expect(klass.location.length).to eq(2)
        end
      end
    end
  end
end
