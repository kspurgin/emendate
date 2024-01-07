# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DateTypes::YearMonthDay do
  subject(:dt) do
    Emendate::DateTypes::YearMonthDay.new(**params)
  end

  let(:params){ { year: year, month: month, day: day, sources: tokens } }

  context 'when from year, month, and day values and sources' do
    let(:str){ '87-4-13' }
    let(:tokens) do
      Emendate.prepped_for(string: str, target: Emendate::DatePartTagger)
    end
    let(:year){ 1987 }
    let(:month){ 4 }
    let(:day){ 13 }

    it 'creates expected datetype' do
      expect(dt.type).to eq(:yearmonthday_date_type)
      expect(dt.earliest).to eq(Date.new(1987, 4, 13))
      expect(dt.lexeme).to eq(str)
      expect(dt.literal).to eq(19870413)
      expect(dt.range?).to be_falsey
    end
  end
end
