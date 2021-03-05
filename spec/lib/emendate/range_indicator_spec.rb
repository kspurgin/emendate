# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::RangeIndicator do

  def indicate(str, options = {})
    pm = Emendate.prep_for(str, :indicate_ranges, options)
    ri = Emendate::RangeIndicator.new(tokens: pm.tokens, options: pm.options)
    ri.indicate
  end

  describe '#indicate' do
    context 'without range present (circa 202127)' do
      before(:all){ @i = indicate('circa 202127') }

      it 'returns original' do
        expect(@i.type_string).to eq('year_date_type')
      end
    end

    context 'with range present (1972 - 1999)' do
      before(:all){ @i = indicate('1972 - 1999') }

      it 'returns range_date_type' do
        expect(@i.type_string).to eq('range_date_type')
      end
    end
  end
end
