# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::Options do
  context 'when default' do
    let(:opt){ described_class.new } 

    it 'returns requested option' do
      expect(opt.ambiguous_month_day).to eq(:as_month_day)
    end
  end

  context 'when custom' do
    let(:opt){ described_class.new(opthash) }
    let(:opthash){ {ambiguous_month_day: :as_day_month} }
    it 'returns requested option' do
      expect(opt.ambiguous_month_day).to eq(:as_day_month)
    end

    context 'with unknown key included' do
      let(:opthash){ {not_option: :as_day_month} }
      it 'raises error' do
        err = Emendate::UnknownOptionError
        expect{ opt }.to raise_error(err, 'not_option')
      end
    end

    context 'with unknown value for option' do
      let(:opthash){ {ambiguous_month_day: :as_month} }
      it 'raises error' do
        err = Emendate::UnknownOptionValueError
        m = <<~MSG
        as_month is not an accepted value for the ambiguous_month_day option. Use one of the following instead: as_month_day, as_day_month
        MSG
        expect{ opt }.to raise_error(err, m.chomp)
      end
    end

    context 'with edtf: true' do
      let(:opthash){ {edtf: true} }
      it 'sets other options as expected' do
        expect(opt.beginning_hyphen).to eq(:edtf)
        expect(opt.square_bracket_interpretation).to eq(:edtf_set)
      end
    end

    context 'with custom ambiguous_year_rollback_threshold value' do
      context 'with too many digits' do
        let(:opthash){ {ambiguous_year_rollback_threshold: 500} }
        it 'raises error' do
          err = Emendate::AmbiguousYearRollbackThresholdError
          expect{ opt }.to raise_error(err, 'Must be one or two digit integer')
        end
      end

      context 'with string instead of integer' do
        let(:opthash){ {ambiguous_year_rollback_threshold: '50'} }
        it 'raises error' do
          err = Emendate::AmbiguousYearRollbackThresholdError
          expect{ opt }.to raise_error(err, 'Must be one or two digit integer')
        end
      end

      context 'with good value' do
        let(:opthash){ {ambiguous_year_rollback_threshold: 50} }
        it 'sets option as expected' do
          expect(opt.ambiguous_year_rollback_threshold).to eq(50)
        end
      end
    end

    context 'with custom unknown_date_output_string value' do
      context 'with not a string' do
        let(:opthash){ {unknown_date_output_string: 500} }
        it 'raises error' do
          err = Emendate::UnknownDateOutputStringError
          expect{ opt }.to raise_error(err, 'Must be a String')
        end
      end

      context 'with good value' do
        let(:opthash){ {unknown_date_output_string: 'no known date'} }
        it 'sets option as expected' do
          expect(opt.unknown_date_output_string).to eq('no known date')
        end
      end
    end

    context 'with custom open/unknown start date' do
      let(:opthash){ {open_unknown_start_date: '1500-05-15'} }
      it 'sets option as expected' do
        expect(opt.open_unknown_start_date.year).to eq(1500)
        expect(opt.open_unknown_start_date.month).to eq(5)
        expect(opt.open_unknown_start_date.day).to eq(15)
      end
    end
  end
end
