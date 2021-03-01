require 'spec_helper'

RSpec.describe Emendate::NumberUtils do
  describe '#valid_day?' do
    context 'with not valid (i.e. 42)' do
      it 'returns false' do
        expect(described_class.valid_day?('42')).to be false
      end
    end

    context 'with valid (i.e. 24)' do
      it 'returns true' do
        expect(described_class.valid_day?('24')).to be true
      end
    end
  end

  describe '#valid_month?' do
    context 'with not valid (i.e. 21)' do
      it 'returns false' do
        expect(described_class.valid_month?('21')).to be false
      end
    end

    context 'with valid (i.e. 12)' do
      it 'returns true' do
        expect(described_class.valid_month?('12')).to be true
      end
    end
  end

  describe '#valid_season?' do
    context 'with not valid (i.e. 14)' do
      it 'returns false' do
        expect(described_class.valid_season?('14')).to be false
      end
    end

    context 'with valid (i.e. 24)' do
      it 'returns true' do
        expect(described_class.valid_season?('24')).to be true
      end
    end
  end

  describe '#valid_year?' do
    context 'with not valid (i.e. 9999)' do
      it 'returns false' do
        expect(described_class.valid_year?('9999')).to be false
      end
    end

    context 'with valid (i.e. 1923)' do
      it 'returns true' do
        expect(described_class.valid_year?('1923')).to be true
      end
    end
  end
end
