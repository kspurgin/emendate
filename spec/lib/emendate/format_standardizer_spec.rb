require 'spec_helper'

RSpec.describe Emendate::FormatStandardizer do
  def standardize(str)
    l = Emendate.lex(str)
    t = Helpers.translate_ordinals(l.tokens)
    s = Emendate::FormatStandardizer.new(tokens: t)
    s.standardize
  end
  
  describe '#standardize' do
    context 'when c. 999-1-1' do
      xit 'pads to 4-digit number' do
        result = standardize('c. 999-1-1').types
        expect(result).to eq(%i[circa number4 hyphen number1or2 hyphen number1or2])
      end
    end

    context 'when mid-1990' do
      it 'removes hyphen' do
        result = standardize('mid-1990').types
        expect(result).to eq(%i[partial number4])
      end
    end
    
    context 'when 18th or 19th century' do
      it 'adds century after 18th' do
        result = standardize('18th or 19th century').types
        expect(result).to eq(%i[number1or2 century or number1or2 century])
      end
    end

    context 'when Feb. 15, 999 - February 20, 2020' do
      it 'removes commas after dates' do
        result = standardize('Feb. 15, 999 - February 20, 2020').types
        expect(result).to eq(%i[month_abbr_alpha number1or2 number3 hyphen month_alpha number1or2 number4])
      end
    end
  end
end
