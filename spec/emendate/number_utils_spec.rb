# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::NumberUtils do
  subject(:numutils){ Class.new{ extend Emendate::NumberUtils } }

  describe '#max_season' do
    let(:result){ numutils.max_season }

    it 'returns nil with default options' do
      expect(result).to be_nil
    end

    context 'with max_month_number_handling: :edtf_level_1' do
      before{ Emendate.config.options.max_month_number_handling = :edtf_level_1 }

      it 'returns 24' do
        expect(result).to eq(24)
      end
    end

    context 'with max_month_number_handling: :edtf_level_2' do
      before{ Emendate.config.options.max_month_number_handling = :edtf_level_2 }

      it 'returns 41' do
        expect(result).to eq(41)
      end
    end
  end

  describe '#min_season' do
    let(:result){ numutils.min_season }

    it 'returns nil with default options' do
      expect(result).to be_nil
    end

    context 'with max_month_number_handling: :edtf_level_1' do
      before{ Emendate.config.options.max_month_number_handling = :edtf_level_1 }

      it 'returns 21' do
        expect(result).to eq(21)
      end
    end

    context 'with max_month_number_handling: :edtf_level_2' do
      before{ Emendate.config.options.max_month_number_handling = :edtf_level_2 }

      it 'returns 21' do
        expect(result).to eq(21)
      end
    end
  end

  describe '#valid_day?' do
    let(:result){ numutils.valid_day?(str) }

    context 'with not valid (i.e. 42)' do
      let(:str){ '42' }

      it 'returns false' do
        expect(result).to be false
      end
    end

    context 'with valid (i.e. 24)' do
      let(:str){ '24' }

      it 'returns true' do
        expect(result).to be true
      end
    end
  end

  describe '#valid_month?' do
    let(:result){ numutils.valid_month?(int) }

    context 'with not valid (i.e. 21)' do
      let(:int){ 21 }

      it 'returns false' do
        expect(result).to be false
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
    def result(str)
      numutils.valid_month_or_season?(str)
    end

    it 'returns expected with defaults' do
      expect(result('6')).to be true
      expect(result('14')).to be false
      expect(result('22')).to be false
      expect(result('40')).to be false
    end

    context 'with max_month_number_handling: :edtf_level_1' do
      before{ Emendate.config.options.max_month_number_handling = :edtf_level_1 }

      it 'returns expected' do
        expect(result('6')).to be true
        expect(result('14')).to be false
        expect(result('22')).to be true
        expect(result('40')).to be false
      end
    end

    context 'with max_month_number_handling: :edtf_level_2' do
      before{ Emendate.config.options.max_month_number_handling = :edtf_level_2 }

      it 'returns expected' do
        expect(result('6')).to be true
        expect(result('14')).to be false
        expect(result('22')).to be true
        expect(result('40')).to be true
      end
    end
  end

  describe '#valid_season?' do
    def result(str)
      numutils.valid_season?(str)
    end

    it 'returns expected with defaults' do
      expect(result('14')).to be false
      expect(result('22')).to be false
      expect(result('40')).to be false
    end

    context 'with max_month_number_handling: :edtf_level_1' do
      before{ Emendate.config.options.max_month_number_handling = :edtf_level_1 }

      it 'returns expected' do
        expect(result('14')).to be false
        expect(result('22')).to be true
        expect(result('40')).to be false
      end
    end

    context 'with max_month_number_handling: :edtf_level_2' do
      before{ Emendate.config.options.max_month_number_handling = :edtf_level_2 }

      it 'returns expected' do
        expect(result('14')).to be false
        expect(result('22')).to be true
        expect(result('40')).to be true
      end
    end
  end

  describe '#valid_year?' do
    let(:result){ numutils.valid_year?(str) }

    context 'with not valid (i.e. 20324)' do
      let(:str){ '20324' }

      it 'returns false' do
        expect(result).to be false
      end
    end

    context 'with valid (i.e. 1923)' do
      let(:str){ '1923' }

      it 'returns true' do
        expect(result).to be true
      end
    end
  end
end
