require 'spec_helper'

RSpec.describe Emendate::SegmentSet do
  before(:all) do
    pm = Emendate.lex('2021-01-29')
    @set = pm.tokens
  end

  describe '#map' do
    context 'when results of mapping are kinds of Segments' do
      it 'returns kind of SegmentSet' do
        res = @set.map{ |t| t.dup }
        expect(res).to be_a_kind_of(Emendate::SegmentSet)
      end
    end
    context 'otherwise' do
      it 'returns Array' do
        expect(@set.types).to be_a(Array)
      end
    end
  end
end
