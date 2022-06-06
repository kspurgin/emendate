# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DateTypes::Year do  
  context 'with `2021`' do
    let(:yr){ described_class.new(literal: '2021') }

    describe '#type' do
      it 'returns as expected' do
        expect(yr.type).to eq(:year_date_type)
      end
    end

    describe '#lexeme' do
      it 'returns 2021' do
        expect(yr.lexeme).to eq('2021')
      end
    end

    describe '#literal' do
      it 'returns 2021' do
        expect(yr.literal).to eq(2021)
      end
    end

    describe '#range?' do
      it 'returns false' do
        expect(yr.range?).to be false
      end
    end

    describe '#earliest' do
      it 'returns Jan 1 of year' do
        expect(yr.earliest).to eq(Date.new(2021, 1, 1))
      end
    end

    describe '#earliest_at_granularity' do
      it 'returns 2021' do
        expect(yr.earliest_at_granularity).to eq('2021')
      end
    end

    describe '#latest' do
      it 'returns December 31 of year' do
        expect(yr.latest).to eq(Date.new(2021, 12, 31))
      end
    end

    describe '#latest_at_granularity' do
      it 'returns 2021' do
        expect(yr.latest_at_granularity).to eq('2021')
      end
    end
  end

  context 'with `early 2021`' do
    let(:yr){ described_class.new(literal: '2021', partial_indicator: 'early') }

    describe '#lexeme' do
      it 'returns 2021' do
        expect(yr.lexeme).to eq('2021')
      end
    end

    describe '#literal' do
      it 'returns 2021' do
        expect(yr.literal).to eq(2021)
      end
    end

    describe '#range?' do
      it 'returns true' do
        expect(yr.range?).to be true
      end
    end

    describe '#earliest' do
      it 'returns Jan 1 of year' do
        expect(yr.earliest).to eq(Date.new(2021, 1, 1))
      end
    end

    describe '#earliest_at_granularity' do
      it 'returns 2021' do
        expect(yr.earliest_at_granularity).to eq('2021')
      end
    end

    describe '#latest' do
      it 'returns April 30 of year' do
        expect(yr.latest).to eq(Date.new(2021, 4, 30))
      end
    end

    describe '#latest_at_granularity' do
      it 'returns 2021' do
        expect(yr.latest_at_granularity).to eq('2021')
      end
    end
  end

  context 'with `mid 2021`' do
    let(:yr){ described_class.new(literal: '2021', partial_indicator: 'mid') }

    describe '#lexeme' do
      it 'returns 2021' do
        expect(yr.lexeme).to eq('2021')
      end
    end

    describe '#literal' do
      it 'returns 2021' do
        expect(yr.literal).to eq(2021)
      end
    end

    describe '#range?' do
      it 'returns true' do
        expect(yr.range?).to be true
      end
    end

    describe '#earliest' do
      it 'returns May 1 of year' do
        expect(yr.earliest).to eq(Date.new(2021, 5, 1))
      end
    end

    describe '#earliest_at_granularity' do
      it 'returns 2021' do
        expect(yr.earliest_at_granularity).to eq('2021')
      end
    end

    describe '#latest' do
      it 'returns August 31 of year' do
        expect(yr.latest).to eq(Date.new(2021, 8, 31))
      end
    end

    describe '#latest_at_granularity' do
      it 'returns 2021' do
        expect(yr.latest_at_granularity).to eq('2021')
      end
    end
  end

  context 'with `late 2021`' do
    let(:yr){ described_class.new(literal: '2021', partial_indicator: 'late') }

    describe '#lexeme' do
      it 'returns 2021' do
        expect(yr.lexeme).to eq('2021')
      end
    end

    describe '#literal' do
      it 'returns 2021' do
        expect(yr.literal).to eq(2021)
      end
    end

    describe '#range?' do
      it 'returns true' do
        expect(yr.range?).to be true
      end
    end

    describe '#earliest' do
      it 'returns September 1 of year' do
        expect(yr.earliest).to eq(Date.new(2021, 9, 1))
      end
    end

    describe '#earliest_at_granularity' do
      it 'returns 2021' do
        expect(yr.earliest_at_granularity).to eq('2021')
      end
    end

    describe '#latest' do
      it 'returns December 31 of year' do
        expect(yr.latest).to eq(Date.new(2021, 12, 31))
      end
    end

    describe '#latest_at_granularity' do
      it 'returns 2021' do
        expect(yr.latest_at_granularity).to eq('2021')
      end
    end
  end

    context 'with `before 2021` and `before_date_treatment: :point` (the default)' do
    let(:yr){ described_class.new(literal: '2021', range_switch: 'before') }

    describe '#lexeme' do
      it 'returns 2021' do
        expect(yr.lexeme).to eq('2021')
      end
    end

    describe '#literal' do
      it 'returns 2021' do
        expect(yr.literal).to eq(2021)
      end
    end

    describe '#range?' do
      it 'returns false' do
        expect(yr.range?).to be false
      end
    end

    describe '#earliest' do
      it 'returns December 31 of previous year' do
        expect(yr.earliest).to eq(Date.new(2020, 12, 31))
      end
    end

    describe '#earliest_at_granularity' do
      it 'returns 2020' do
        expect(yr.earliest_at_granularity).to eq('2020')
      end
    end

    describe '#latest' do
      it 'returns December 31 of previous year' do
        expect(yr.latest).to eq(Date.new(2020, 12, 31))
      end
    end

    describe '#latest_at_granularity' do
      it 'returns 2020' do
        expect(yr.latest_at_granularity).to eq('2020')
      end
    end
    end

    context 'with `before 2021` and `before_date_treatment: :range`' do
      before{ Emendate.config.options.before_date_treatment = :range }
      let(:yr){ described_class.new(literal: '2021', range_switch: 'before') }

      describe '#lexeme' do
        it 'returns 2021' do
          expect(yr.lexeme).to eq('2021')
        end
      end

      describe '#literal' do
        it 'returns 2021' do
          expect(yr.literal).to eq(2021)
        end
      end

      describe '#range?' do
        it 'returns true' do
          expect(yr.range?).to be true
        end
      end

      describe '#earliest' do
        it 'returns 1583-01-01 of previous year' do
          expect(yr.earliest).to eq(Date.new(1583, 1, 1))
        end
      end

      describe '#earliest_at_granularity' do
        it 'returns 1583' do
          expect(yr.earliest_at_granularity).to eq('1583')
        end
      end

      describe '#latest' do
        it 'returns December 31 of previous year' do
          expect(yr.latest).to eq(Date.new(2020, 12, 31))
        end
      end

      describe '#latest_at_granularity' do
        it 'returns 2020' do
          expect(yr.latest_at_granularity).to eq('2020')
        end
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
