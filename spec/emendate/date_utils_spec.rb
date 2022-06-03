# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DateUtils do
  describe '#expand_shorter_digits' do
    it 'expands to match years as expected' do
      ex = [['2020', '10'], ['2020', '40'], ['1998', '9'], ['1850', '925']]
      res = ex.map{ |arr| described_class.expand_shorter_digits(arr[0], arr[1]) }
      expect(res).to eq(['2010', '2040', '1999', '1925'])
    end
  end

  describe '#is_range?' do
    context 'with 1910-11' do
      it 'returns false' do
        res = described_class.is_range?('1910', '11')
        expect(res).to be false
      end
    end

    context 'with 1950-52' do
      it 'returns true' do
        res = described_class.is_range?('1950', '52')
        expect(res).to be true
      end
    end
  end

  describe '#month_abbr_literal' do
    it 'returns expected' do
      expect(described_class.month_abbr_literal('Sep.')).to eq(9)
      expect(described_class.month_abbr_literal('Sept.')).to eq(9)
      expect(described_class.month_abbr_literal('September')).to be_nil
    end
  end
  
  describe '#month_literal' do
    it 'returns expected' do
      expect(described_class.month_literal('September')).to eq(9)
      expect(described_class.month_literal('Sept.')).to be_nil
    end
  end
  
  describe '#possible_range' do
    context 'with 2020-10 (10 must be October)' do
      it 'returns false' do
        res = described_class.possible_range?('2020', '10')
        expect(res).to be false
      end
    end

    context 'with 2020-40 (2040 not a valid year)' do
      it 'returns false' do
        res = described_class.possible_range?('2020', '40')
        expect(res).to be false
      end
    end

    context 'with 2020-21' do
      it 'returns true (may be range or Spring 2020)' do
        res = described_class.possible_range?('2020', '21')
        expect(res).to be true
      end
    end
  end

  describe '#valid_date?' do
    # a range of dates in October 1582 do not exist/are not valid using the default
    #  (Italian) Gregorian date adoption assumptions.
    context 'with valid date - 2020-02-29' do
      it 'returns true' do
        pm = Emendate.prep_for('2020-02-29', :tag_date_parts)
        t = pm.standardized_formats
        expect(described_class.valid_date?(t[0], t[2], t[4])).to be true
      end
    end

    context 'with invalid date - 2020-02-92' do
      it 'returns false' do
        pm = Emendate.prep_for('2020-02-92', :tag_date_parts)
        t = pm.standardized_formats
        expect(described_class.valid_date?(t[0], t[2], t[4])).to be false
      end
    end

    context 'with date invalid in Italy, valid in England - 1582-10-14' do
      it 'returns true' do
        pm = Emendate.prep_for('1582-10-14', :tag_date_parts)
        t = pm.standardized_formats
        expect(described_class.valid_date?(t[0], t[2], t[4])).to be true
      end
    end
  end

end
