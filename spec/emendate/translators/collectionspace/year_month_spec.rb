# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::Translators::Collectionspace::YearMonth do
  let(:options) do
    {
      dialect: :collectionspace
    }
  end
  let(:translation){ Emendate.translate(str, options) }
  let(:value){ translation.values[0] }
  let(:warnings){ translation.warnings[0] }

  context 'with January 1984' do
    let(:str){ 'January 1984' }
    let(:expected) do
      {
        dateDisplayDate: 'January 1984',
        scalarValuesComputed: 'true',
        dateEarliestScalarValue: '1984-01-01T00:00:00.000Z',
        dateEarliestSingleYear: '1984',
        dateEarliestSingleMonth: '1',
        dateEarliestSingleDay: '1',
        dateEarliestSingleEra: 'CE',
        dateLatestScalarValue: '1984-01-31T00:00:00.000Z',
        dateLatestYear: '1984',
        dateLatestMonth: '1',
        dateLatestDay: '31',
        dateLatestEra: 'CE'
      }
    end
    it 'translates as expected' do
      expect(value).to eq(expected)
      expect(warnings).to be_empty
    end
  end
end
