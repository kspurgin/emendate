require 'spec_helper'

RSpec.describe Emendate::DatePartTagger do
  def tag(str)
    pm = Emendate.process(str)
    pm.tagged_date_parts.types
  end
  
  describe '#tag' do
    context 'when 999' do
      it 'tags year' do
        result = tag('999')
        expect(result).to eq(%i[year])
      end
    end
    context 'when 2020' do
      it 'tags year' do
        result = tag('2020')
        expect(result).to eq(%i[year])
      end
    end
    context 'when March' do
      it 'tags month' do
        result = tag('March')
        expect(result).to eq(%i[month])
      end
    end
    context 'when 1990s' do
      it 'tags decade' do
        result = tag('1990s')
        expect(result).to eq(%i[decade])
      end
    end
    context 'when 199X' do
      it 'tags decade' do
        result = tag('199X')
        expect(result).to eq(%i[decade])
      end
    end
    context 'when 19th century' do
      it 'tags century' do
        result = tag('19th century')
        expect(result).to eq(%i[century])
      end
    end

    context 'when February 15, 2020' do
      it 'tags day (month and year are already done at this point)' do
        result = tag('February 15, 2020')
        expect(result).to eq(%i[month day year])
      end
    end

    context 'when February 30, 2020' do
      xit 'returns error' do
        pm = Emendate.prep_for('February 30, 2020', :tag_date_parts)
        expect(result).to eq(%i[month day year])
      end
    end

    context 'when 02-03-2020' do
      context 'default' do
        xit 'tags month day year' do
          result = tag('02-03-2020')
          expect(result).to eq(%i[month day year])
        end
      end
    end

    xit 'test' do
      pm = Emendate.process('c. 2001-02-20?')
      # circa => 0
      # 2001 => 1
      # - => 2
      # 02 => 3
      # - => 4
      # 20 => 5
      # ? => 6
      t = pm.standardized_formats
      dpt = Emendate::DatePartTagger.new(tokens: t)
      seg = dpt.extract_pattern(:number4, :hyphen, :number1or2)
    end
  end
end
