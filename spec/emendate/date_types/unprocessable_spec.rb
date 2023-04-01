# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DateTypes::Unprocessable do
  subject(:datetype){ described_class.new(sources: sources) }
  let(:sources) do
    pf = prepped_for(
      string: 'Y-20987654',
      target: Emendate::UnprocessableTagger
    )
  end

  context 'with lexeme' do

    it 'returns as expected' do
      expect(datetype.type).to eq(:unprocessable_date_type)
      expect(datetype.lexeme).to eq('Y-20987654')
      expect(datetype.literal).to be_nil
      expect(datetype.date_part?).to be true
      expect(datetype.date_type?).to be true
      expect(datetype.earliest).to be nil
      expect(datetype.latest).to be nil
      expect(datetype.range?).to be false
      expect(datetype.earliest_at_granularity).to be nil
      expect(datetype.latest_at_granularity).to be nil
      expect(datetype.location).to eq(datetype.sources.location)
    end
  end
end
