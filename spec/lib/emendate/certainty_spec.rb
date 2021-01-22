require 'spec_helper'

RSpec.describe Emendate::Certainty do
  describe '#eof' do
    before(:all) do
      @l = Emendate::Lexer.new('1 2 3')
      @l.start_tokenization
    end
    context 'tokens include eof' do
      before(:all){ @c = Emendate::Certainty.new(tokens: @l.tokens) }
      it 'captures orig eof token' do
        expect(@c.eof).to be_a(Emendate::Token)
      end
      it 'removes eof token from working tokens list' do
        chk = @c.tokens.select{ |t| t.type == :eof }
        expect(chk).to be_empty
      end
    end
    context 'tokens do not include eof' do
      it 'is nil' do
        c = Emendate::Certainty.new(tokens: @l.tokens[0..2])
        expect(c.eof).to be_nil
      end
    end
  end
  
  describe '#check' do
    context '[circa 2002?]' do
      before(:all) do
        l = Emendate::Lexer.new('[circa 2002?]')
        l.start_tokenization
        @c = Emendate::Certainty.new(tokens: l.tokens).check
      end
      it 'values include: supplied, approximate, and questionable' do
        res = @c.values.sort
        expect(res).to eq([:approximate, :questionable, :supplied])
      end
      it 'returns 2 tokens for 2002 and eof' do
        res = @c.tokens.map(&:type).join(' ')
        expect(res).to eq('number4 eof')
      end
    end

    context 'c. 2002' do
      before(:all) do
        l = Emendate::Lexer.new('c. 2002')
        l.start_tokenization
        @c = Emendate::Certainty.new(tokens: l.tokens).check
      end
      it 'values include: approximate' do
        res = @c.values.sort
        expect(res).to eq([:approximate])
      end
      it 'returns 2 tokens for 2002 and eof' do
        res = @c.tokens.map(&:type).join(' ')
        expect(res).to eq('number4 eof')
      end
    end

    context '[1997]-[1998]' do
      before(:all) do
        @l = Emendate::Lexer.new('[1997]-[1998]')
        @l.start_tokenization
        @c = Emendate::Certainty.new(tokens: @l.tokens).check
      end
      it 'no values' do
        expect(@c.values).to be_empty
      end
      it 'returns all original tokens' do
        expect(@c.tokens).to eq(@l.tokens)
      end
    end
  end
end
