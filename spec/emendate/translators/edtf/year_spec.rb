# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::Translators::Edtf::Year do
  let(:options){ {target_dialect: :edtf} }
  let(:translation){ Emendate.translate(str, options) }
  let(:value){ translation.value }
  let(:warnings){ translation.warnings }

  context 'with 2002' do
    let(:str){ '2002' }
    it 'value = 2002' do
      expect(value).to eq('2002')
      expect(warnings).to be_empty
    end
  end  
end
