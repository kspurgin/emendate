require 'spec_helper'

RSpec.describe Emendate::DatePartTagger do
  describe '#tag' do
    context 'YYYY' do
      it 'tags as expected' do
        l = Emendate::Lexer.new('Jan 2021')
        l.start_tokenization
        t = Emendate::DatePartTagger.new(tokens: l.tokens)
        tagged = t.tag
        binding.pry
#        expect(@c.eof).to be_a(Emendate::Token)
      end
    end
  end
end
