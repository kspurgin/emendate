require 'spec_helper'

RSpec.describe Emendate::OrdinalTranslator do
  describe '#translate' do
    context 'when ordinal indicator appears after a 1 or 2 digit number' do
      it 'removes ordinal indicator' do
        l = Emendate.lex('20th')
        c = Emendate::OrdinalTranslator.new(tokens: l.tokens)
        c.translate
        result = c.result.map(&:type)
        expect(result).to eq([:number1or2])
      end
    end

    context 'when ordinal indicator is first element' do
      it 'raises error' do
        l = Emendate.lex('th20')
        c = Emendate::OrdinalTranslator.new(tokens: l.tokens)
        expect{ c.translate }.to raise_error(Emendate::UnexpectedInitialOrdinalError)
      end
    end

    context 'when ordinal indicator appears after NOT a 1 or 2 digit number' do
      it 'raises error' do
        l = Emendate.lex('9999th')
        c = Emendate::OrdinalTranslator.new(tokens: l.tokens)
        expect{ c.translate }.to raise_error(Emendate::UnexpectedOrdinalError)
      end
    end

  end
end
