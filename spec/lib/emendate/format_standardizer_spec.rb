require 'spec_helper'

RSpec.describe Emendate::FormatStandardizer do
  def standardize(str, options = {})
    pm = Emendate.prep_for(str, :standardize_formats, options)
    fs = Emendate::FormatStandardizer.new(tokens: pm.tokens, options: pm.options)
    fs.standardize.types
  end
  
  describe '#standardize' do
    context 'when 1997/98' do
      it 'replace slash with hyphen' do
        result = standardize('1997/98')
        expect(result).to eq(%i[number4 hyphen number1or2])
      end
    end

    context 'when c. 999-1-1' do
      it 'pads to 4-digit number' do
        result = standardize('c. 999-1-1')
        expect(result).to eq(%i[approximate number4 hyphen number1or2 hyphen number1or2])
      end
    end

    context 'when mid-1990' do
      it 'removes hyphen' do
        result = standardize('mid-1990')
        expect(result).to eq(%i[partial number4])
      end
    end
    
    context 'when 18th or 19th century' do
      it 'adds century after 18th' do
        result = standardize('18th or 19th century')
        expect(result).to eq(%i[number1or2 century or number1or2 century])
      end
    end

    context 'when Feb. 15, 999 - February 20, 2020' do
      it 'removes commas after dates' do
        result = standardize('Feb. 15, 999 - February 20, 2020')
        expect(result).to eq(%i[number_month number1or2 number4 hyphen number_month number1or2 number4])
      end
    end

    context 'May - June 2000' do
      it 'adds year after first month' do
        result = standardize('May - June 2000')
        expect(result).to eq(%i[number_month number4 hyphen number_month number4])
      end
    end

    context 'June 1- July 4, 2000' do
      it 'adds year after first month/day' do
        result = standardize('June 1- July 4, 2000')
        expect(result).to eq(%i[number_month number1or2 number4 hyphen number_month number1or2 number4])
      end
    end

    context 'June 3-15, 2000' do
      it 'adds year after first month/day; adds month before day/year' do
        result = standardize('June 3-15, 2000')
        expect(result).to eq(%i[number_month number1or2 number4 hyphen number_month number1or2 number4])
      end
    end

    context '2000 May -June' do
      it 'move first month to front; copy year to end' do
        result = standardize('2000 May -June')
        expect(result).to eq(%i[number_month number4 hyphen number_month number4])
      end
    end

    context '2000 June 3-2001 Jan 20' do
      it 'move year to end of segment' do
        result = standardize('2000 June 3-2001 Jan 20')
        expect(result).to eq(%i[number_month number1or2 number4 hyphen number_month number1or2 number4])
      end
    end

    context '15 Feb 2020' do
      it 'move month to front of segment' do
        result = standardize('15 Feb 2020')
        expect(result).to eq(%i[number_month number1or2 number4])
      end
    end
  end
end
