# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::OrdinalTranslator do
  def translate(str, options = {})
    pm = Emendate.prep_for(str, :translate_ordinals, options)
    t = Emendate::OrdinalTranslator.new(tokens: pm.tokens)
    t.translate
  end

  describe '#translate' do
    context 'with ordinal indicator appearing after a 1 or 2 digit number' do
      it 'removes ordinal indicator' do
        result = translate('20th').type_string
        expect(result).to eq('number1or2')
      end
    end

    context 'with no ordinal indicator' do
      it 'returns original token set' do
        result = translate('2000').type_string
        expect(result).to eq('number4')
      end
    end

    context 'with ordinal indicator as first element' do
      before(:all) do
        @t = translate('th20')
      end

      it 'warns' do
        ex = 'Ordinal indicator unexpectedly appears at beginning of date string'
        expect(@t.warnings).to include(ex)
      end

      it 'removes ordinal indicator' do
        expect(@t.type_string).to eq('number1or2')
      end
    end

    context 'with ordinal indicator appearing after NOT a 1 or 2 digit number' do
      before(:all) do
        @t = translate('22nd to 9999th')
      end

      it 'warns' do
        ex = 'Ordinal indicator expected after :number1or2. Found after :number4'
        expect(@t.warnings).to include(ex)
      end

      it 'removes ordinal indicator' do
        expect(@t.type_string).to eq('number1or2 range_indicator number4')
      end
    end
  end
end
