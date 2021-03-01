require 'spec_helper'

RSpec.describe Emendate::Options do
  context 'when default' do
    before(:all) do
      @opt = described_class.new
    end

    it 'returns requested option' do
      expect(@opt.ambiguous_month_day).to eq(:as_month_day)
    end
  end

  context 'when custom' do
    it 'returns requested option' do
      opt = described_class.new(ambiguous_month_day: :as_day_month)
      expect(opt.ambiguous_month_day).to eq(:as_day_month)
    end

    context 'with unknown key included' do
      it 'raises error' do
        err = Emendate::UnknownOptionError
        expect{described_class.new(not_option: :as_day_month) }.to raise_error(err, 'not_option')
      end
    end

    context 'with unknown value for option' do
      it 'raises error' do
        err = Emendate::UnknownOptionValueError
        m = <<~MSG
        as_month is not an accepted value for the ambiguous_month_day option. Use one of the following instead: as_month_day, as_day_month
        MSG
        expect{described_class.new(ambiguous_month_day: :as_month) }.to raise_error(err, m.chomp)
      end
    end
  end
end
