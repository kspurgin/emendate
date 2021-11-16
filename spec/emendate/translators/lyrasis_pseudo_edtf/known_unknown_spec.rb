# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::Translators::LyrasisPseudoEdtf::KnownUnknown do
  let(:outstr){ 'not dated' }
  let(:options) do
    {
      target_dialect: :lyrasis_pseudo_edtf,
      unknown_date_output: :custom,
      unknown_date_output_string: outstr
    }
  end
  let(:translation){ Emendate.translate(str, options) }
  let(:value){ translation.value }
  let(:warnings){ translation.warnings }

  context 'with unknown' do
    let(:str){ 'unknown' }
    it 'translates as expected' do
      expect(value).to eq(outstr)
      expect(warnings).to be_empty
    end
  end
end
