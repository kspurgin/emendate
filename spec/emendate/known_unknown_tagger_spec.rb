# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::KnownUnknownTagger do
  def tag(str, options = {})
    pm = Emendate.prep_for(str, :tag_known_unknown, options)
    fs = described_class.new(tokens: pm.tokens, str: str, options: pm.options)
    fs.tag
  end

  describe '#tag' do
    context 'with n.d.' do
      it 'tags as expected' do
        result = tag('n.d.')
        expect(result.types).to eq(%i[knownunknown_date_type])
      end
    end
  end
end
