# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::ResultEditable do
  class Editable
    include Emendate::ResultEditable

    attr_reader :result

    def initialize(tokens)
      @result = tokens
    end
  end
  
  def convert(str, options = {})
    fs = Emendate::AlphaMonthConverter.new(tokens: pm.tokens, options: pm.options)
    binding.pry
    fs.convert.segments
  end

  describe '#replace_x_with_new' do
    it 'tags as expected' do
      tokens = Emendate.prep_for('Jan 2021', :convert_months).tokens
      e = Editable.new(tokens)
      e.replace_x_with_new(x: tokens[0], new: tokens[2])
      expect(e.result.type_string).to eq('number4 number4')
    end
  end
end
