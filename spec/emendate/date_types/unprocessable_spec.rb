# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DateTypes::Unprocessable do
  subject(:datetype){ described_class }
  let(:children) do
    pf = prepped_for(
      string: 'Y-20987654',
      target: Emendate::UnprocessableTagger
    )
  end

  context 'with lexeme' do
    let(:result) do
      datetype.new(children: children.segments)
    end

    it 'returns as expected' do
      expect(result.type).to eq(:unprocessable_date_type)
      expect(result.lexeme).to eq('y-20987654')
      expect(result.literal).to eq(0)
      expect(result.date_part?).to be true
      expect(result.date_type?).to be true
      expect(result.earliest).to be nil
      expect(result.latest).to be nil
      expect(result.range?).to be false
      expect(result.earliest_at_granularity).to be nil
      expect(result.latest_at_granularity).to be nil
      expect(result.location).to eq(children.location)
    end
  end
end
