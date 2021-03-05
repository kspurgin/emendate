# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Emendate::DateTypes::Range do
  def prep(str, options = {})
    pm = Emendate.process(str, options)
    pm.segmented_dates
  end

  context 'with 1900 to 1985' do
    before(:all) do
      res = prep('1900 to 1985')
      @r = described_class.new(startdate: res[0],
                               range_indicator: res[1],
                               enddate: res[2])
    end

    it 'earliest = 1900-01-01' do
      expect(@r.earliest).to eq(Date.new(1900,1,1))
    end

    it 'latest = 1985-12-31' do
      expect(@r.latest).to eq(Date.new(1985,12,31))
    end

    it 'lexeme = 1900-01-01 - 1985-12-31' do
      expect(@r.lexeme).to eq('1900-01-01 - 1985-12-31')
    end
  end
end
