# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DateTypes::RangeDateUnknown do
  subject(:datetype) do
    described_class.new(**args)
  end
  let(:args){ {} }


  describe '#type' do
    let(:args){ {usage: :start} }

    it 'type = :rangedateopen_date_type' do
      expect(datetype.type).to eq(:rangedateunknown_date_type)
    end
  end

  context 'with usage = :start ' do
    let(:args){ {usage: :start} }

    it 'returns values for default datevalue: 1583-1-1' do
      expect(datetype.earliest).to eq(Date.new(1583, 1, 1))
      expect(datetype.latest).to be_nil
      expect(datetype.lexeme).to eq('unknown start date')
      expect(datetype.literal).to eq(15830101)
      expect(datetype.range?).to be false
      expect(datetype.year).to eq('1583')
    end

    context 'with custom datevalue: 1900-01-01' do
      before(:context) do
        Emendate.config.options.open_unknown_start_date =
          Date.new(1900, 1, 1)
      end
      after(:context){ Emendate.reset_config }

      it 'returns values for custom datevalue' do
        expect(datetype.earliest).to eq(Date.new(1900, 1, 1))
        expect(datetype.latest).to be_nil
        expect(datetype.lexeme).to eq('unknown start date')
        expect(datetype.literal).to eq(19000101)
        expect(datetype.range?).to be false
        expect(datetype.year).to eq('1900')
      end
    end
  end

  context 'with usage = :end ' do
    let(:args){ {usage: :end} }

    it 'returns values for default datevalue: 2999-12-31' do
      expect(datetype.earliest).to be_nil
      expect(datetype.latest).to eq(Date.new(2999, 12, 31))
      expect(datetype.lexeme).to eq('unknown end date')
      expect(datetype.literal).to eq(29991231)
      expect(datetype.range?).to be false
      expect(datetype.year).to eq('2999')
    end

    context 'with custom datevalue: 2050-01-01' do
      before(:context) do
        Emendate.config.options.open_unknown_end_date =
          Date.new(2050, 1, 1)
      end
      after(:context){ Emendate.reset_config }

      it 'returns values for custom datevalue' do
        expect(datetype.earliest).to be_nil
        expect(datetype.latest).to eq(Date.new(2050, 1, 1))
        expect(datetype.lexeme).to eq('unknown end date')
        expect(datetype.literal).to eq(20500101)
        expect(datetype.range?).to be false
        expect(datetype.year).to eq('2050')
      end
    end
  end
end
