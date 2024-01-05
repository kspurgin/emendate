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
      expect(result('1910', '11')).to be false
      expect(result('1950', '52')).to be true
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

  describe '#valid_date?' do
    let(:tokens){ Emendate.prepped_for(
      string: str,
      target: Emendate::DatePartTagger
    )
    }
    let(:args){ [tokens[0], tokens[2], tokens[4]] }
    let(:result){ dateutils.valid_date?(*args) }

    context 'with valid date - 2020-02-29' do
      let(:str){ '2020-02-29' }

      it 'returns true' do
        expect(result).to be true
      end
    end

    context 'with invalid date - 2020-02-92' do
      let(:str){ '2020-02-92' }

      it 'returns false' do
        expect(result).to be false
      end
    end

    # a range of dates in October 1582 do not exist/are not valid using the default
    #  (Italian) Gregorian date adoption assumptions.
    context 'with date invalid in Italy, valid in England - 1582-10-14' do
      let(:str){ '1582-10-14' }

      it 'returns true' do
        expect(result).to be true
      end
    end
  end
end
