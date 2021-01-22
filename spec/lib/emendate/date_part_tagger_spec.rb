require 'spec_helper'

RSpec.describe Emendate::DatePartTagger do
  describe '#tag' do
    context 'YYYY' do
      it 'tags as expected' do
        l = Emendate.lex('Jan 2021')
        t = Emendate::DatePartTagger.new(tokens: l.tokens)
        tagged = t.tag
#        expect(@c.eof).to be_a(Emendate::Token)
      end
    end
  end
end
