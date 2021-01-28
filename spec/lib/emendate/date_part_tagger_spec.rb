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
  end
end
