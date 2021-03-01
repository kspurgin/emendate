require 'spec_helper'

RSpec.describe Emendate::SegmentSet do
    before(:all) do
      @set = Emendate::SegmentSet.new(%i[a b c d].map{ |t| Emendate::Token.new(type: t) })
    end

    describe '#extract' do
      context 'when given subset' do
        it 'extracts subset' do
          types = [:b, :c]
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
        expect(res).to be_a_kind_of(Emendate::SegmentSet)
      end
    end
    context 'when results of mapping are not kinds of Segments' do
      it 'returns Array' do
        expect(@set.types).to be_a(Array)
      end
    end
  end
end
