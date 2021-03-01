require 'spec_helper'

RSpec.describe Emendate::Options do
  context 'when default' do
    before(:all) do
      @opt = Emendate::Options.new
    end
    it 'returns requested option' do
      expect(@opt.ambiguous_month_day).to eq(:as_month_day)
    end
  end

  context 'when custom' do
    it 'returns requested option' do
      opt = Emendate::Options.new(ambiguous_month_day: :as_day_month)
      expect(opt.ambiguous_month_day).to eq(:as_day_month)
    end

    context 'with unknown key included' do
      it 'raises error' do
        expect{ Emendate::Options.new(not_option: :as_day_month) }.to raise_error(Emendate::UnknownOptionError, 'not_option')
      end
    end
    context 'with unknown value for option' do
      it 'raises error' do
        m = 'as_month is not an accepted value for the ambiguous_month_day option. Use one of the following instead: as_month_day, as_day_month'
        expect{ Emendate::Options.new(ambiguous_month_day: :as_month) }.to raise_error(Emendate::UnknownOptionValueError, m)
      end
    end
  end
end
