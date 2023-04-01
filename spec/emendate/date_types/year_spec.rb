# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DateTypes::Year do
  subject(:yr){ described_class.new(**args) }

  context 'with `2021`' do
    let(:args){ {literal: '2021'} }

    it 'returns as expected' do
      expect(yr.type).to eq(:year_date_type)
      expect(yr.lexeme).to eq('2021')
      expect(yr.literal).to eq(2021)
      expect(yr.range?).to be false
      expect(yr.earliest).to eq(Date.new(2021, 1, 1))
      expect(yr.earliest_at_granularity).to eq('2021')
      expect(yr.latest).to eq(Date.new(2021, 12, 31))
      expect(yr.latest_at_granularity).to eq('2021')
    end
  end

  context 'with `early 2021`' do
    let(:args){ { literal: '2021', partial_indicator: 'early'} }

    it 'returns 2021' do
      expect(yr.lexeme).to eq('2021')
      expect(yr.literal).to eq(2021)
      expect(yr.range?).to be true
      expect(yr.earliest).to eq(Date.new(2021, 1, 1))
      expect(yr.earliest_at_granularity).to eq('2021')
      expect(yr.latest).to eq(Date.new(2021, 4, 30))
      expect(yr.latest_at_granularity).to eq('2021')
    end
  end

  context 'with `mid 2021`' do
    let(:args){ {literal: '2021', partial_indicator: 'mid'} }

    it 'returns 2021' do
      expect(yr.lexeme).to eq('2021')
      expect(yr.literal).to eq(2021)
      expect(yr.range?).to be true
      expect(yr.earliest).to eq(Date.new(2021, 5, 1))
      expect(yr.earliest_at_granularity).to eq('2021')
      expect(yr.latest).to eq(Date.new(2021, 8, 31))
      expect(yr.latest_at_granularity).to eq('2021')
    end
  end

  context 'with `late 2021`' do
    let(:args){ {literal: '2021', partial_indicator: 'late'} }

    it 'returns 2021' do
      expect(yr.lexeme).to eq('2021')
      expect(yr.literal).to eq(2021)
      expect(yr.range?).to be true
      expect(yr.earliest).to eq(Date.new(2021, 9, 1))
      expect(yr.earliest_at_granularity).to eq('2021')
      expect(yr.latest).to eq(Date.new(2021, 12, 31))
      expect(yr.latest_at_granularity).to eq('2021')
    end
  end

  context 'with `before 2021`' do
    let(:args){ {literal: '2021', range_switch: 'before'} }

    it 'returns 2021' do
      expect(yr.lexeme).to eq('2021')
      expect(yr.literal).to eq(2021)
      expect(yr.range?).to be false
      expect(yr.earliest).to eq(Date.new(2020, 12, 31))
      expect(yr.earliest_at_granularity).to eq('2020')
      expect(yr.latest).to eq(Date.new(2020, 12, 31))
      expect(yr.latest_at_granularity).to eq('2020')
    end
    context 'with `before 2021` and `before_date_treatment: :range`' do
      before(:context){ Emendate.config.options.before_date_treatment = :range }
      after(:context){ Emendate.reset_config }

      it 'returns 2021' do
        expect(yr.lexeme).to eq('2021')
        expect(yr.literal).to eq(2021)
        expect(yr.range?).to be true
        expect(yr.earliest).to eq(Date.new(1583, 1, 1))
        expect(yr.earliest_at_granularity).to eq('1583')
        expect(yr.latest).to eq(Date.new(2020, 12, 31))
        expect(yr.latest_at_granularity).to eq('2020')
      end
    end
  end

  context 'with `230 CE`' do
    let(:args){ {literal: '230'} }

    it 'returns expected' do
      expect(yr.lexeme).to eq('0230')
      expect(yr.literal).to eq(230)
      expect(yr.range?).to be false
      expect(yr.earliest).to eq(Date.new(230, 1, 1))
      expect(yr.earliest_at_granularity).to eq('0230')
      expect(yr.latest).to eq(Date.new(230, 12, 31))
      expect(yr.latest_at_granularity).to eq('0230')
    end
  end

  context 'with `231 BCE`' do
    let(:args){ {literal: '0231'} }

    it 'returns expected' do
      yr.bce
      expect(yr.lexeme).to eq('-0230')
      expect(yr.literal).to eq(-230)
      expect(yr.range?).to be false
      expect(yr.earliest).to eq(Date.new(-230, 1, 1))
      expect(yr.earliest_at_granularity).to eq('-0230')
      expect(yr.latest).to eq(Date.new(-230, 12, 31))
      expect(yr.latest_at_granularity).to eq('-0230')
    end
  end

  # describe '#earliest' do
  #   context 'with after' do
  #     it 'returns 2022-01-01' do
  #       yr = described_class.new(literal: '2021', range_switch: 'after')
  #       expect(yr.earliest).to eq(Date.new(2022, 1, 1))
  #     end
  #   end

  #   context 'with after early' do
  #     it 'returns 2021-05-01' do
  #       yr = described_class.new(literal: '2021', partial_indicator: 'early', range_switch: 'after')
  #       expect(yr.earliest).to eq(Date.new(2021, 5, 1))
  #     end
  #   end
  # end

  # describe '#latest' do
  #   context 'with after' do
  #     it 'returns current date' do
  #       yr = described_class.new(literal: '2021', range_switch: 'after')
  #       expect(yr.latest).to eq(Date.today)
  #     end
  #   end

  #   context 'with before mid' do
  #     it 'returns 2021-07-31' do
  #       yr = described_class.new(literal: '2021', partial_indicator: 'mid', range_switch: 'before')
  #       expect(yr.latest).to eq(Date.new(2021, 4, 30))
  #     end
  #   end
  # end


  # describe '#range?' do
  #   context 'with range_switch' do
  #     it 'returns true' do
  #       yr = described_class.new(literal: '2021', range_switch: 'before')
  #       expect(yr.range?).to be true
  #     end
  #   end

  #   context 'with partial_indicator and range_switch' do
  #     it 'returns true' do
  #       yr = described_class.new(literal: '2021', partial_indicator: 'early', range_switch: 'before')
  #       expect(yr.range?).to be true
  #     end
  #   end
  # end
end
