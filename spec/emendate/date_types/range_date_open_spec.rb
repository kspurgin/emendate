# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DateTypes::RangeDateOpen do
  subject(:open) do
    Emendate::DateTypes::RangeDateOpen.new(**args)
  end
  let(:args){ {} }


  describe '#type' do
    let(:args){ {usage: :start} }

    it 'type = :rangedateopen_date_type' do
      expect(open.type).to eq(:rangedateopen_date_type)
    end
  end

  context 'with usage = :start ' do
    let(:args){ {usage: :start} }

    it 'returns values for default datevalue: 1583-1-1' do
      expect(open.earliest).to eq(Date.new(1583, 1, 1))
      expect(open.latest).to be_nil
      expect(open.lexeme).to eq('open start date')
      expect(open.literal).to eq(15830101)
      expect(open.range?).to be false
      expect(open.year).to eq('1583')
    end

    context 'with custom datevalue: 1900-01-01' do
      before(:context) do
        Emendate.config.options.open_unknown_start_date =
          Date.new(1900, 1, 1)
      end
      after(:context){ Emendate.reset_config }

      it 'returns values for custom datevalue' do
        expect(open.earliest).to eq(Date.new(1900, 1, 1))
        expect(open.latest).to be_nil
        expect(open.lexeme).to eq('open start date')
        expect(open.literal).to eq(19000101)
        expect(open.range?).to be false
        expect(open.year).to eq('1900')
      end
    end
  end

  context 'with usage = :end ' do
    let(:args){ {usage: :end} }

    it 'returns values for default datevalue: 2999-12-31' do
      expect(open.earliest).to be_nil
      expect(open.latest).to eq(Date.new(2999, 12, 31))
      expect(open.lexeme).to eq('open end date')
      expect(open.literal).to eq(29991231)
      expect(open.range?).to be false
      expect(open.year).to eq('2999')
    end

    context 'with custom datevalue: 2050-01-01' do
      before(:context) do
        Emendate.config.options.open_unknown_end_date =
          Date.new(2050, 1, 1)
      end
      after(:context){ Emendate.reset_config }

      it 'returns values for custom datevalue' do
        expect(open.earliest).to be_nil
        expect(open.latest).to eq(Date.new(2050, 1, 1))
        expect(open.lexeme).to eq('open end date')
        expect(open.literal).to eq(20500101)
        expect(open.range?).to be false
        expect(open.year).to eq('2050')
      end
    end
  end
end
