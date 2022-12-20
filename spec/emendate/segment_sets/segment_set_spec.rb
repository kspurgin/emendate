# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::SegmentSets::SegmentSet do
  subject(:set){ described_class }
  let(:segments){ %i[a b c d].map{ |t| Emendate::Token.new(type: t) } }
  let(:string){ 'str' }
  let(:segset){ set.new(string: string, segments: segments) }

  describe '.new' do
    context 'with no args' do
      it 'initializes as expected' do
        result = set.new
        expect(result.orig_string).to be_nil
        expect(result.segments).to be_empty
      end
    end

    context 'with string arg' do
      it 'initializes as expected' do
        result = set.new(string: string)
        expect(result.orig_string).to eq(string)
        expect(result.segments).to be_empty
      end
    end

    context 'with segments' do
      it 'initializes as expected' do
        result = set.new(segments: segments)
        expect(result.orig_string).to be_nil
        expect(result.segments.length).to eq(4)
      end
    end

    context 'with string and segments' do
      it 'initializes as expected' do
        result = set.new(string: string, segments: segments)
        expect(result.orig_string).to eq(string)
        expect(result.segments.length).to eq(4)
      end
    end
  end

  describe '#<<' do
    it 'adds segment as expected' do
      segset << Emendate::Token.new(type: :z)
      expect(segset.segments.length).to eq(5)
    end
  end

  describe '#add_certainty' do
    it 'adds certainty value(s) as expected' do
      segset.add_certainty(:a)
      segset.add_certainty(%i[p q])
      expect(segset.certainty).to eq(%i[a p q])
    end
  end

  describe '#copy' do
    it 'copies as expected' do
      newset = set.new.copy(segset)
      result = set.new(string: string, segments: segments)
      expect(result.orig_string).to eq(string)
      expect(result.segments.length).to eq(4)
    end
  end

  describe '#extract' do
    let(:result){ segset.extract(types) }

    context 'when given subset' do
      let(:types){ %i[b c] }

      it 'extracts subset' do
        expect(result).to be_a(set)
        expect(result.types).to eq(types)
      end
    end

    context 'when given full match' do
      let(:types){ %i[a b c d] }

      it 'returns copy of whole set' do
        expect(result.types).to eq(types)
      end
    end

    context 'when given more types than in set' do
      let(:types){ %i[a b c d e] }

      it 'returns empty set' do
        expect(result.types).to be_empty
      end
    end
  end

  describe '#map' do
    context 'when results of mapping are kinds of Segments' do
      let(:result){ segset.map{ |t| t.dup } }

      it 'returns kind of SegmentSet' do
        expect(result).to be_a_kind_of(described_class)
      end
    end

    context 'when results of mapping are not kinds of Segments' do
      let(:result){ segset.map{ |t| t.lexeme } }

      it 'returns Array' do
        expect(result).to be_a(Array)
      end
    end
  end
end
