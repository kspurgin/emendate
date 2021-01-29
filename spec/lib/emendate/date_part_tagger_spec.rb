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
  end
end
