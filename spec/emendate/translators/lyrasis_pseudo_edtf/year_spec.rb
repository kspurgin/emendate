# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::Translators::LyrasisPseudoEdtf::Year do
  let(:options){ {dialect: :lyrasis_pseudo_edtf} }
  let(:translation){ Emendate.translate(str, options) }
  let(:value){ translation.values[0] }
  let(:warnings){ translation.warnings[0] }

  context 'with 2002' do
    let(:str){ '2002' }
    it 'translates as expected' do
      expect(value).to eq('2002')
      expect(warnings).to be_empty
    end
  end

  context 'with [circa 2002]' do
    let(:str){ '[circa 2002]' }
    it 'translates as expected' do
      expect(value).to eq('2002 (approximate)')
      expect(warnings).to be_empty
    end
  end

  context 'with circa 2002?' do
    let(:str){ 'circa 2002?' }
    it 'translates as expected' do
      expect(value).to eq('2002 (uncertain and approximate)')
      expect(warnings).to be_empty
    end
  end
end
