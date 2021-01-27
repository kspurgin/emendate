require 'spec_helper'

RSpec.describe Emendate::FormatStandardizer do
  def standardize(str)
    l = Emendate.lex(str)
    t = Helpers.translate_ordinals(l.tokens)
    s = Emendate::FormatStandardizer.new(tokens: t)
    s.standardize
  end
  
  describe '#standardize' do
    context 'when mid-1990' do
      it 'becomes mid 1990' do
        result = standardize('mid-1990').map(&:type)
        expect(result).to eq(%i[partial number4])
      end

    end
    
    context 'when 18th or 19th century' do
      it 'becomes 18th century or 19th century' do
        result = standardize('18th or 19th century').map(&:type)
        expect(result).to eq(%i[number1or2 century or number1or2 century])
      end
    end
  end
end
