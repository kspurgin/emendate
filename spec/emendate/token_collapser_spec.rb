# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::TokenCollapser do
  def collapse(str, options = {})
    pm = Emendate.prep_for(str, :collapse_tokens, options)
    tc = described_class.new(tokens: pm.tokens, options: pm.options)
    tc.collapse
  end

  describe '#collapse' do
    context 'with "Jan. 2014"' do
      it 'collapses space and single dot' do
        c = collapse('Jan. 2014')
        expect(c.type_string).to eq('month_abbr_alpha number4')
      end
    end

    context 'with "2014.0"' do
      it 'drops `.0` at end' do
        c = collapse('2014.0')
        expect(c.type_string).to eq('number4')
      end
    end
  end
end
