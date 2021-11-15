# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::SegmentSet do
    before(:all) do
      @set = described_class.new(%i[a b c d].map{ |t| Emendate::Token.new(type: t) })
    end

    describe '#extract' do
      context 'when given subset' do
        it 'extracts subset' do
          types = %i[b c]
          res = @set.extract(types)
          expect(res.types).to eq(types)
        end
      end

      context 'when given full match' do
        it 'returns copy of whole set' do
          types = %i[a b c d]
          res = @set.extract(types)
          expect(res.types).to eq(types)
        end
      end

      context 'when given more types than in set' do
        it 'returns empty set' do
          types = %i[a b c d e]
          res = @set.extract(types)
          expect(res).to be_empty
        end
      end
    end

    describe '#map' do
      context 'when results of mapping are kinds of Segments' do
        it 'returns kind of SegmentSet' do
          res = @set.map{ |t| t.dup }
          expect(res).to be_a_kind_of(described_class)
        end
      end

      context 'when results of mapping are not kinds of Segments' do
        it 'returns Array' do
          expect(@set.types).to be_a(Array)
        end
      end
    end
end
