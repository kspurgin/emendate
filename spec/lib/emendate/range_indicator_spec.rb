require 'spec_helper'

RSpec.describe Emendate::RangeIndicator do

  def indicate(str, options = {})
    pm = Emendate.prep_for(str, :indicate_ranges, options)
    ri = Emendate::RangeIndicator.new(tokens: pm.tokens, options: pm.options)
    ri.indicate
  end
  
  describe '#indicate' do
    context 'no range present' do
      context 'circa 202127' do
        before(:all){ @i = indicate('circa 202127') }
        it 'returns original' do
          expect(@i.type_string).to eq('year_date_type')
        end
      end
    end
  end
end
