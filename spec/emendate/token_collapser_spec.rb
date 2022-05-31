# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::TokenCollapser do
  def collapse(str, options = {})
    pm = Emendate.prep_for(str, :collapse_tokens, options)
    tc = described_class.new(tokens: pm.tokens, options: pm.options)
    tc.collapse
  end

  describe '#collapse' do
    context 'with "Jan. 21, 2014"' do
      it 'collapses space and single dot' do
        c = collapse('Jan. 21, 2014')
        expect(c.type_string).to eq('month_abbr_alpha number1or2 comma number4')
      end
    end

    context 'with "2014.0"' do
      it 'drops `.0` at end' do
        c = collapse('2014.0')
        expect(c.type_string).to eq('number4')
      end
    end

    context 'with "3/2020"' do
      it 'collapse slash into 3' do
        c = collapse('3/2020')
        expect(c.type_string).to eq('number1or2 number4')
      end
    end

    context 'with "pre-1750"' do
      it 'collapses - into pre' do
        c = collapse('pre-1750')
        expect(c.type_string).to eq('before number4')
      end
    end

    context 'with "mid-1750"' do
      it 'collapses - into mid' do
        c = collapse('mid-1750')
        expect(c.type_string).to eq('partial number4')
      end
    end
  end
end
