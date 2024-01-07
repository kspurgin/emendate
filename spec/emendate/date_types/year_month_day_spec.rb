# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DateTypes::YearMonthDay do
  subject(:dt) do
    Emendate::DateTypes::YearMonthDay.new(**params)
  end

  let(:baseparams){ { year: year, month: month, day: day } }
  let(:params){ baseparams }

  context 'when from year, month, and day values' do
    let(:year){ '2020' }
    let(:month){ 2 }
    let(:day){ '29' }

    it 'creates expected datetype' do
      expect(dt.type).to eq(:yearmonthday_date_type)
      expect(dt.earliest).to eq(Date.new(2020, 2, 29))
      expect(dt.latest).to eq(Date.new(2020, 2, 29))
      expect(dt.lexeme).to eq('20200229')
      expect(dt.literal).to eq(20200229)
    end

    context 'when 3-digit year' do
      let(:year){ 600 }
      let(:month){ 4 }
      let(:day){ 21 }

      it 'creates expected datetype' do
        expect(dt.literal).to eq(6000421)
      end
    end
  end

  context 'when from year, month, and day values and sources' do
    let(:str){ '87-4-13' }
    let(:tokens) do
      Emendate.prepped_for(string: str, target: Emendate::DatePartTagger)
    end
    let(:params){ baseparams.merge({ sources: tokens }) }
    let(:year){ 1987 }
    let(:month){ 4 }
    let(:day){ 13 }

    it 'creates expected datetype' do
      expect(dt.type).to eq(:yearmonthday_date_type)
      expect(dt.earliest).to eq(Date.new(1987, 4, 13))
      expect(dt.lexeme).to eq(str)
      expect(dt.literal).to eq(19870413)
    end
  end
end
