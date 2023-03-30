# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::OldKnownUnknownTagger do
  def tag(str, options = {})
    pm = Emendate.prep_for(str, :tag_known_unknown, options)
    fs = described_class.new(tokens: pm.tokens, str: str)
    fs.tag
  end

  describe '#tag' do
    context 'with default options (orig unknowndate output) and `n.d.`' do
      it 'tags as expected' do
        result = tag('n.d.')
        expect(result.types).to eq(%i[knownunknown_date_type])
        expect(result[0].lexeme).to eq('n.d.')
      end
    end

    context 'with default options (orig unknowndate output) and `Date Unknown`' do
      it 'tags as expected' do
        result = tag('Date Unknown')
        expect(result.types).to eq(%i[knownunknown_date_type])
        expect(result[0].lexeme).to eq('Date Unknown')
      end
    end

    context 'with custom output' do
      it 'tags as expected' do
        opt = {
          unknown_date_output: :custom,
          unknown_date_output_string: 'unknown date'
        }
        result = tag('n.d.', opt)
        expect(result.types).to eq(%i[knownunknown_date_type])
        expect(result[0].lexeme).to eq('unknown date')
      end
    end
  end
end
