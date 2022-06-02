# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::Translators::LyrasisPseudoEdtf::KnownUnknown do
  before{ Emendate.reset_config }
  
  let(:translation){ Emendate.translate(str, options) }
  let(:value){ translation.value }
  let(:warnings){ translation.warnings }

  context 'with orig unknown date output' do
    let(:str){ 'n.d.' }
    let(:options){ {target_dialect: :lyrasis_pseudo_edtf} }
    
    it 'translates as expected' do
      expect(value).to eq(str)
      expect(warnings).to be_empty
    end
  end
  
  context 'with custom unknown date output' do
    context 'when unknown date output string provided' do
      let(:str){ 'unknown' }
      let(:outstr){ 'not dated' }
      let(:options) do
        {
          target_dialect: :lyrasis_pseudo_edtf,
          unknown_date_output: :custom,
          unknown_date_output_string: outstr
        }
      end

      it 'translates as expected' do
        expect(value).to eq(outstr)
        expect(warnings).to be_empty
    end
      end
  end
end

