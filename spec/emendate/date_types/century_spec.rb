# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DateTypes::Century do
  context 'when called without century_type' do
    it 'raises error' do
      err = Emendate::DateTypes::MissingCenturyTypeError
      expect{described_class.new(literal: 19) }.to raise_error(err)
    end
  end

  context 'when called with unsupported century_type value' do
    it 'raises error' do
      err = Emendate::DateTypes::CenturyTypeValueError
      expect{described_class.new(literal: 19, century_type: :misc) }.to raise_error(err)
    end
  end

  context 'with textual century name (19th)' do
    before(:all) do
      @dt = described_class.new(literal: 19, century_type: :name)
    end

    it 'type = :century_date_type' do
      expect(@dt.type).to eq(:century_date_type)
    end

    describe '#earliest' do
      context 'without partial_indicator' do
        it 'returns 1801-01-01' do
          expect(@dt.earliest).to eq(Date.new(1801, 1, 1))
        end
      end

      context 'with early' do
        it 'returns 1801-01-01' do
          dt = described_class.new(literal: 19, century_type: :name, partial_indicator: 'early')
          expect(dt.earliest).to eq(Date.new(1801, 1, 1))
        end
      end

      context 'with mid' do
        it 'returns 1834-01-01' do
          dt = described_class.new(literal: 19, century_type: :name, partial_indicator: 'mid')
          expect(dt.earliest).to eq(Date.new(1834, 1, 1))
        end
      end

      context 'with late' do
        it 'returns 1867-01-01' do
          dt = described_class.new(literal: 19, century_type: :name, partial_indicator: 'late')
          expect(dt.earliest).to eq(Date.new(1867, 1, 1))
        end
      end
    end

    describe '#latest' do
      context 'without partial_indicator' do
        it 'returns 1900-12-31' do
          expect(@dt.latest).to eq(Date.new(1900, 12, 31))
        end
      end

      context 'with early' do
        it 'returns 1834-12-31' do
          dt = described_class.new(literal: 19, century_type: :name, partial_indicator: 'early')
          expect(dt.latest).to eq(Date.new(1834, 12, 31))
        end
      end

      context 'with mid' do
        it 'returns 1867-12-31' do
          dt = described_class.new(literal: 19, century_type: :name, partial_indicator: 'mid')
          expect(dt.latest).to eq(Date.new(1867, 12, 31))
        end
      end

      context 'with late' do
        it 'returns 1900-12-31' do
          dt = described_class.new(literal: 19, century_type: :name, partial_indicator: 'late')
          expect(dt.latest).to eq(Date.new(1900, 12, 31))
        end
      end
    end

    describe '#earliest_at_granularity' do
      context 'without partial_indicator' do
        it 'returns 1801' do
          expect(@dt.earliest_at_granularity).to eq(1801)
        end
      end
    end

    describe '#lexeme' do
      it 'returns 19 century' do
        expect(@dt.lexeme).to eq('19 century')
      end
    end
  end

  context 'with plural century (1900s)' do
    before(:all) do
      @dt = described_class.new(literal: 19, century_type: :plural)
    end

    describe '#earliest' do
      context 'without partial_indicator' do
        it 'returns 1900-01-01' do
          expect(@dt.earliest).to eq(Date.new(1900, 1, 1))
        end
      end

      context 'with early' do
        it 'returns 1900-01-01' do
          dt = described_class.new(literal: 19, century_type: :plural, partial_indicator: 'early')
          expect(dt.earliest).to eq(Date.new(1900, 1, 1))
        end
      end

      context 'with mid' do
        it 'returns 1933-01-01' do
          dt = described_class.new(literal: 19, century_type: :plural, partial_indicator: 'mid')
          expect(dt.earliest).to eq(Date.new(1933, 1, 1))
        end
      end

      context 'with late' do
        it 'returns 1966-01-01' do
          dt = described_class.new(literal: 19, century_type: :plural, partial_indicator: 'late')
          expect(dt.earliest).to eq(Date.new(1966, 1, 1))
        end
      end
    end

    describe '#latest' do
      context 'without partial_indicator' do
        it 'returns 1999-12-31' do
          expect(@dt.latest).to eq(Date.new(1999, 12, 31))
        end
      end

      context 'with early' do
        it 'returns 1933-12-31' do
          dt = described_class.new(literal: 19, century_type: :plural, partial_indicator: 'early')
          expect(dt.latest).to eq(Date.new(1933, 12, 31))
        end
      end

      context 'with mid' do
        it 'returns 1966-12-31' do
          dt = described_class.new(literal: 19, century_type: :plural, partial_indicator: 'mid')
          expect(dt.latest).to eq(Date.new(1966, 12, 31))
        end
      end

      context 'with late' do
        it 'returns 1999-12-31' do
          dt = described_class.new(literal: 19, century_type: :plural, partial_indicator: 'late')
          expect(dt.latest).to eq(Date.new(1999, 12, 31))
        end
      end
    end

    describe '#latest_at_granularity' do
      context 'without partial_indicator' do
        it 'returns 1999' do
          expect(@dt.latest_at_granularity).to eq(1999)
        end
      end
    end

    describe '#lexeme' do
      it 'returns 1900s' do
        expect(@dt.lexeme).to eq('1900s')
      end
    end
  end

  context 'with uncertainty_digit century (19uu)' do
    before(:all) do
      @dt = described_class.new(literal: 19, century_type: :uncertainty_digits)
    end

    describe '#earliest' do
      it 'returns 1900-01-01' do
        expect(@dt.earliest).to eq(Date.new(1900, 1, 1))
      end
    end

    describe '#latest' do
      it 'returns 1999-12-31' do
        expect(@dt.latest).to eq(Date.new(1999, 12, 31))
      end
    end

    describe '#lexeme' do
      it 'returns 19uu' do
        expect(@dt.lexeme).to eq('19uu')
      end
    end
  end
end
