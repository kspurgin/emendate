# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::Translators::Edtf::YearMonth do
  let(:options){ {target_dialect: :edtf, ambiguous_month_year: :as_month} }
  let(:translation){ Emendate.translate(str, options) }
  let(:value){ translation.value }
  let(:warnings){ translation.warnings }

  context 'with 2002-10' do
    let(:str){ '2002-10' }
    it 'translates as expected' do
      expect(value).to eq('2002-10')
      expect(warnings).to eq(['Ambiguous year + month/season/year treated as_month'])
    end
  end

  context 'with ca. 2002-10' do
    let(:str){ 'ca. 2002-10' }
    it 'translates as expected' do
      expect(value).to eq('2002-10~')
      expect(warnings).to eq(['Ambiguous year + month/season/year treated as_month'])
    end
  end
end
