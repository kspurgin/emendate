# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::Translators::Edtf::Century do
  let(:options){ {target_dialect: :edtf} }
  let(:translation){ Emendate.translate(str, options) }
  let(:value){ translation.value }
  let(:warnings){ translation.warnings }

  context 'with 19th c.' do
    let(:str){ '19th c.' }
    it 'translates as expected' do
      expect(value).to eq('[1801..1900]')
      expect(warnings).to eq([])
    end
  end
end