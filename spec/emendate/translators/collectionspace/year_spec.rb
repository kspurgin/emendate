# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::Translators::Collectionspace::Year do
  let(:options) do
    {
      target_dialect: :collectionspace
    }
  end
  let(:translation){ Emendate.translate(str, options) }
  let(:value){ translation.value }
  let(:warnings){ translation.warnings }

  context 'with 2012' do
    let(:str){ '2012' }
    let(:expected) do
      {
        dateDisplayDate: '2012',
        scalarValuesComputed: 'true',
        dateEarliestScalarValue: '2012-01-01T00:00:00.000Z',
        dateEarliestSingleYear: '2012',
        dateEarliestSingleMonth: '1',
        dateEarliestSingleDay: '1',
        dateEarliestSingleEra: 'CE',
        dateLatestScalarValue: '2012-12-31T00:00:00.000Z',
        dateLatestYear: '2012',
        dateLatestMonth: '12',
        dateLatestDay: '31',
        dateLatestEra: 'CE'
      }
    end
    it 'translates as expected' do
      expect(value).to eq(expected)
      expect(warnings).to be_empty
    end
  end

  context 'with 2002 B.C.' do
    let(:str){ '2002 B.C.' }
    let(:expected) do
      {
        dateDisplayDate: '2002 B.C.',
        scalarValuesComputed: 'true',
        dateEarliestScalarValue: '2002-01-01T00:00:00.000Z',
        dateEarliestSingleYear: '2002',
        dateEarliestSingleMonth: '1',
        dateEarliestSingleDay: '1',
        dateEarliestSingleEra: 'BCE',
        dateLatestScalarValue: '2002-12-31T00:00:00.000Z',
        dateLatestYear: '2002',
        dateLatestMonth: '12',
        dateLatestDay: '31',
        dateLatestEra: 'BCE'
      }
    end
    it 'translates as expected', skip: 'fix post de-aasm-ing' do
      expect(value).to eq(expected)
      expect(warnings).to be_empty
    end
  end
end