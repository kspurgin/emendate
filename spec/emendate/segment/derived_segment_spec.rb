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
        orig_token = Emendate::Token.new(type: :sym, lexeme: 'str', literal: 1)
        orig_token.add_certainty(:approximate)
        [orig_token]
      end

      it 'derives values as expected' do
        expect(klass.type).to eq(:newtype)
        expect(klass.lexeme).to eq('str')
        expect(klass.literal).to eq(1)
      end
    end

    context 'when multiple sources' do
      context 'when all sources have numeric literals' do
        let(:sources) do
          t1 = Emendate::Token.new(type: :sym, lexeme: 'a ', literal: 1)
          t1.add_certainty(:approximate)
          t2 = Emendate::Token.new(type: :foo, lexeme: 'cat ', literal: 2)
          t3 = Emendate::Token.new(type: :bar, lexeme: 'sat', literal: 3)
          [t1, t2, t3]
        end

        it 'derives values as expected' do
          expect(klass.type).to eq(:newtype)
          expect(klass.lexeme).to eq('a cat sat')
          expect(klass.literal).to eq(123)
        end
      end

      context 'when sources have numeric and nil literals (1985.0)' do
        let(:sources) do
          [
            Emendate::NumberToken.new(type: :number, lexeme: '1985'),
            Emendate::Token.new(type: :single_dot, lexeme: '.'),
            Emendate::NumberToken.new(type: :number, lexeme: '0')
          ]
        end
        let(:derived_type){ :number }

        it 'derives values as expected' do
          expect(klass.type).to eq(:number)
          expect(klass.lexeme).to eq('1985.0')
          expect(klass.literal).to eq(1985)
        end
      end

      context 'one source has symbol literal (mid )' do
        let(:sources) do
          [
            Emendate::Token.new(type: :partial, lexeme: 'mid', literal: :mid),
            Emendate::Token.new(type: :space, lexeme: ' ', literal: nil)
          ]
        end
        let(:derived_type){ :partial }

        it 'derives values as expected' do
          expect(klass.type).to eq(:partial)
          expect(klass.lexeme).to eq('mid ')
          expect(klass.literal).to eq(:mid)
        end
      end

      context 'no sources have numeric or symbol literals (, )' do
        let(:sources) do
          [
            Emendate::Token.new(type: :comma, lexeme: ','),
            Emendate::Token.new(type: :space, lexeme: ' ')
          ]
        end
        let(:derived_type){ :comma }

        it 'derives values as expected' do
          expect(klass.type).to eq(:comma)
          expect(klass.lexeme).to eq(', ')
          expect(klass.literal).to be_nil
        end
      end

      context 'with mixed Integer and Symbol literals' do
        let(:sources) do
          [
            Emendate::Token.new(type: :partial, lexeme: 'mid', literal: :mid),
            Emendate::NumberToken.new(type: :number, lexeme: '1985')
          ]
        end

        it 'raises error' do
          expect{ klass }.to raise_error(Emendate::DerivedSegmentError,
                                         /Cannot derive literal from mixed Integers and Symbols/)
        end
      end

      context 'with multiple Symbol literals' do
        let(:sources) do
          [
            Emendate::Token.new(type: :partial, lexeme: 'mid', literal: :mid),
            Emendate::Token.new(type: :partial, lexeme: 'mid', literal: :mid)
          ]
        end

        it 'raises error' do
          expect{ klass }.to raise_error(Emendate::DerivedSegmentError,
                                         /Cannot derive literal from multiple symbols/)
        end
      end

      context 'with unexpected literal pattern' do
        let(:sources) do
          [
            Emendate::Token.new(type: :partial, lexeme: 'mid', literal: :mid),
            Emendate::Token.new(type: :string, lexeme: 'mid', literal: 'string')
          ]
        end

        it 'raises error' do
          expect{ klass }.to raise_error(Emendate::DerivedSegmentError,
                                         /Cannot derive literal for unknown reason/)
        end
      end

      context 'with multiple levels of derivation' do
        it 'foo' do
          sub_a_srcs = [
            Emendate::NumberToken.new(type: :number, lexeme: '2'),
            Emendate::Token.new(type: :hyphen, lexeme: '/')
          ]
          sub_a = Derivable.new(type: :sub_a, sources: sub_a_srcs)

          sub_b_srcs = [
            Emendate::Token.new(type: :question, lexeme: '?'),
            Emendate::Token.new(type: :space, lexeme: ' ')
          ]
          sub_b = Derivable.new(type: :sub_b, sources: sub_b_srcs)

          parent = Derivable.new(type: :nested, sources: [sub_a, sub_b])
          expect(parent.type).to eq(:nested)
          expect(parent.sources.length).to eq(4)
        end
      end
    end
  end
end
