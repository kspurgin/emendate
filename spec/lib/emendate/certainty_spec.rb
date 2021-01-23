require 'spec_helper'

RSpec.describe Emendate::Certainty do
  describe '#check' do
    context '[circa 2002?]' do
      before(:all) do
        l = Emendate.lex('[circa 2002?]')
        c = Emendate::Certainty.new(tokens: l.tokens)
        @c = c.check
      end
      it 'values include: supplied, approximate, and questionable' do
        res = @c.values.sort
        expect(res).to eq([:approximate, :questionable, :supplied])
      end
      it 'returns 1 token for 2002' do
        res = @c.result.map(&:type).join(' ')
        expect(res).to eq('number4')
      end
    end

    context 'c. 2002' do
      before(:all) do
        l = Emendate.lex('c. 2002')
        c = Emendate::Certainty.new(tokens: l.tokens)
        @c = c.check
      end
      it 'values include: approximate' do
        res = @c.values.sort
        expect(res).to eq([:approximate])
      end
      it 'returns 1 token for 2002' do
        res = @c.result.map(&:type).join(' ')
        expect(res).to eq('number4')
      end
    end

    context '[1997]-[1998]' do
      before(:all) do
        @l = Emendate.lex('[1997]-[1998]')
        c = Emendate::Certainty.new(tokens: @l.tokens)
        @c = c.check
      end
      it 'no values' do
        expect(@c.values).to be_empty
      end
      it 'returns all original tokens' do
        expect(@c.result).to eq(@l.tokens)
      end
    end
  end
end
