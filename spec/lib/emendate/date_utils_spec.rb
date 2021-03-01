require 'spec_helper'

RSpec.describe Emendate::DateUtils do
  describe '#ambiguous_post_year_value?' do
    context 'with 2020-10 (10 must be October)' do
      it 'returns false' do
        res = Emendate::DateUtils.ambiguous_post_year_value?('2020', '10')
        expect(res).to be false
      end
    end
    context 'with 1950-52 (52 must be 1952)' do
      it 'returns false' do
        res = Emendate::DateUtils.ambiguous_post_year_value?('1950', '52')
        expect(res).to be false
      end
    end
    context 'with 1910-12 (12 could be December or 1912)' do
      it 'returns true' do
        res = Emendate::DateUtils.ambiguous_post_year_value?('1910', '12')
        expect(res).to be true
      end
    end
  end

  describe '#expand_shorter_digits' do
    it 'expands to match years as expected' do
      ex = [['2020', '10'], ['2020', '40'], ['1998', '9'], ['1850','925']]
      res = ex.map{ |arr| Emendate::DateUtils.expand_shorter_digits(arr[0], arr[1]) }
      expect(res).to eq(['2010', '2040', '1999', '1925'])
    end
  end

  describe '#is_range?' do
    context 'with 1910-11' do
      it 'returns false' do
        res = Emendate::DateUtils.is_range?('1910', '11')
        expect(res).to be false
      end
    end
    context 'with 1950-52' do
      it 'returns true' do
        res = Emendate::DateUtils.is_range?('1950', '52')
        expect(res).to be true
      end
    end
  end

  describe '#possible_range' do
    context 'with 2020-10 (10 must be October)' do
      it 'returns false' do
        res = Emendate::DateUtils.possible_range?('2020', '10')
        expect(res).to be false
      end
    end
    context 'with 2020-40 (2040 not a valid year)' do
      it 'returns false' do
        res = Emendate::DateUtils.possible_range?('2020', '40')
        expect(res).to be false
      end
    end
    context 'with 2020-21' do
      it 'returns true (may be range or Spring 2020)' do
        res = Emendate::DateUtils.possible_range?('2020', '21')
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
        expect(Emendate::DateUtils.valid_date?(t[0], t[2], t[4])).to be true
      end
    end
    context 'with invalid date - 2020-02-92' do
      it 'returns false' do
        pm = Emendate.prep_for('2020-02-92', :tag_date_parts)
        t = pm.standardized_formats
        expect(Emendate::DateUtils.valid_date?(t[0], t[2], t[4])).to be false
      end
    end
    context 'with date invalid in Italy, valid in England - 1582-10-14' do
      it 'returns true' do
        pm = Emendate.prep_for('1582-10-14', :tag_date_parts)
        t = pm.standardized_formats
        expect(Emendate::DateUtils.valid_date?(t[0], t[2], t[4])).to be true
      end
    end
  end

end
