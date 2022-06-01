# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::Options do
  before{ Emendate.reset_config }

  let(:config_opts){ Emendate.config.options.values }
  
  context 'when called with no option hash' do
    it 'uses default settings' do
      defaults = config_opts.dup
      result = described_class.new
      expect(config_opts).to eq(defaults)
    end
  end

  context 'when called with option hash' do
    let(:call_options){ described_class.new(opthash) }

    context 'with valid setting' do
      let(:opthash){ {ambiguous_month_day: :as_day_month} }
      it 'sets option' do
        call_options
        expect(Emendate.options.ambiguous_month_day).to eq(:as_day_month)
      end
    end

    context 'with unknown option key' do
      let(:opthash){ {foo: :bar} }
      it 'outputs message to STDOUT and exits' do
        expect{ call_options }.to output(/:foo option is not allowed/).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'with unknown value for option' do
      let(:opthash){ {ambiguous_month_day: :as_month} }
      it 'outputs message to STDOUT and exits' do
        msg = /:ambiguous_month_day option :as_month is not a an allowed value\. Use one of: :as_month_day, :as_day_month/
        expect{ call_options }.to output(msg).to_stdout.and raise_error(SystemExit)
      end
    end

    context 'with edtf: true' do
      let(:opthash){ {edtf: true} }
      it 'sets other options as expected' do
        call_options
        expect(Emendate.options.beginning_hyphen).to eq(:edtf)
        expect(Emendate.options.square_bracket_interpretation).to eq(:edtf_set)
      end
    end
  end
end
