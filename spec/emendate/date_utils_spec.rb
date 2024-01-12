# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DateUtils do
  subject(:dateutils){ Class.new{ extend Emendate::DateUtils } }

  describe '#expand_shorter_digits' do
    def result(yr, digits)
      dateutils.expand_shorter_digits(yr, digits)
    end

    it 'expands to match years as expected' do
      expect(result('2020', '10')).to eq('2010')
      expect(result('2020', '40')).to eq('2040')
      expect(result('1998', '9')).to eq('1999')
      expect(result('1850', '925')).to eq('1925')
    end
  end

  describe '#is_range?' do
    def result(yr, digits)
      dateutils.is_range?(yr, digits)
    end

    it 'expands to match years as expected' do
      expect(result(1910, 11)).to be false
      expect(result(1950, 52)).to be true
    end
  end

  describe '#max_season' do
    let(:result){ dateutils.max_season }

    it 'returns nil with default options' do
      expect(result).to be_nil
    end

    context 'with max_month_number_handling: :edtf_level_1' do
      before do
        Emendate.config.options.max_month_number_handling = :edtf_level_1
      end

      it 'returns 24' do
        expect(result).to eq(24)
      end
    end

    context 'with max_month_number_handling: :edtf_level_2' do
      before do
        Emendate.config.options.max_month_number_handling = :edtf_level_2
      end

      it 'returns 41' do
        expect(result).to eq(41)
      end
    end
  end

  describe '#min_season' do
    let(:result){ dateutils.min_season }

    it 'returns nil with default options' do
      expect(result).to be_nil
    end

    context 'with max_month_number_handling: :edtf_level_1' do
      before do
        Emendate.config.options.max_month_number_handling = :edtf_level_1
      end

      it 'returns 21' do
        expect(result).to eq(21)
      end
    end

    context 'with max_month_number_handling: :edtf_level_2' do
      before do
        Emendate.config.options.max_month_number_handling = :edtf_level_2
      end

      it 'returns 21' do
        expect(result).to eq(21)
      end
    end
  end

  describe '#month_abbr_literal' do
    def result(month)
      dateutils.month_abbr_literal(month)
    end

    it 'returns expected literals' do
      expect(result('Sep.')).to eq(9)
      expect(result('Sept.')).to eq(9)
      expect(result('September')).to be_nil
    end
  end

  describe '#month_literal' do
    def result(month)
      dateutils.month_literal(month)
    end

    it 'returns expected' do
      expect(result('September')).to eq(9)
      expect(result('Sept.')).to be_nil
    end
  end

  describe '#possible_range' do
    let(:result){ dateutils.possible_range?(*args) }

    context 'with 2020-10 (10 must be October)' do
      let(:args){ %w[2020 10] }

      it 'returns false' do
        expect(result).to be false
      end
    end

    context 'with 2020-21' do
      let(:args){ %w[2020 21] }

      it 'returns true (may be range or Spring 2020)' do
        expect(result).to be true
      end
    end
  end

  describe '#valid_day?' do
    let(:result){ dateutils.valid_day?(val) }

    context 'with not valid (i.e. 42)' do
      let(:val){ 42 }

      it 'returns false' do
        expect(result).to be false
      end
    end

    context 'with valid (i.e. 24)' do
      let(:val){ 24 }

      it 'returns true' do
        expect(result).to be true
      end
    end
  end

  describe '#valid_date?' do
    let(:tokens) do
      Emendate.prepped_for(
        string: val,
        target: Emendate::DatePartTagger
      )
    end
    let(:args){ [tokens[0], tokens[2], tokens[4]] }
    let(:result){ dateutils.valid_date?(*args) }

    context 'with valid date - 2020-02-29' do
      let(:val){ '2020-02-29' }

      it 'returns true' do
        expect(result).to be true
      end
    end

    context 'with invalid date - 2020-02-92' do
      let(:val){ '2020-02-92' }

      it 'returns false' do
        expect(result).to be false
      end
    end

    # a range of dates in October 1582 do not exist/are not valid using the default
    #  (Italian) Gregorian date adoption assumptions.
    context 'with date invalid in Italy, valid in England - 1582-10-14' do
      let(:val){ '1582-10-14' }

      it 'returns true' do
        expect(result).to be true
      end
    end
  end

  describe '#valid_month?' do
    let(:result){ dateutils.valid_month?(int) }

    context 'with not valid (i.e. 21)' do
      let(:int){ 21 }

      it 'returns false' do
        expect(result).to be_falsey
      end
    end

    context 'with valid (i.e. 12)' do
      let(:int){ 12 }

      it 'returns true' do
        expect(result).to be true
      end
    end
  end

  describe '#valid_month_or_season' do
    def result(val)
      dateutils.valid_month_or_season?(val)
    end

    it 'returns expected with defaults' do
      expect(result(6)).to be true
      expect(result(14)).to be false
      expect(result(22)).to be false
      expect(result(40)).to be false
    end

    context 'with max_month_number_handling: :edtf_level_1' do
      before{ Emendate.config.options.max_month_number_handling = :edtf_level_1 }

      it 'returns expected' do
        expect(result(6)).to be true
        expect(result(14)).to be false
        expect(result(22)).to be true
        expect(result(40)).to be false
      end
    end

    context 'with max_month_number_handling: :edtf_level_2' do
      before{ Emendate.config.options.max_month_number_handling = :edtf_level_2 }

      it 'returns expected' do
        expect(result(6)).to be true
        expect(result(14)).to be false
        expect(result(22)).to be true
        expect(result(40)).to be true
      end
    end
  end

  describe '#valid_season?' do
    def result(val)
      dateutils.valid_season?(val)
    end

    it 'returns expected with defaults' do
      expect(result(14)).to be false
      expect(result(22)).to be false
      expect(result(40)).to be false
    end

    context 'with max_month_number_handling: :edtf_level_1' do
      before{ Emendate.config.options.max_month_number_handling = :edtf_level_1 }

      it 'returns expected' do
        expect(result(14)).to be false
        expect(result(22)).to be true
        expect(result(40)).to be false
      end
    end

    context 'with max_month_number_handling: :edtf_level_2' do
      before{ Emendate.config.options.max_month_number_handling = :edtf_level_2 }

      it 'returns expected' do
        expect(result(14)).to be false
        expect(result(22)).to be true
        expect(result(40)).to be true
      end
    end
  end

  describe '#valid_year?' do
    let(:result){ dateutils.valid_year?(val) }

    context 'with not valid (i.e. 20324)' do
      let(:val){ '20324' }

      it 'returns false' do
        expect(result).to be false
      end
    end

    context 'with valid (i.e. 1923)' do
      let(:val){ '1923' }

      it 'returns true' do
        expect(result).to be true
      end
    end
  end
end
