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
  
  describe '#collapse_token_pair_backward' do
    it 'collapses as expected' do
      tokens = Emendate.prep_for('Jan 2021', :collapse_tokens).tokens
      e = Editable.new(tokens)
      e.collapse_token_pair_backward(tokens[0], tokens[1])
      expect(e.result.type_string).to eq('month_abbr_alpha number4')
    end
  end

  describe '#collapse_token_pair_forward' do
    it 'collapses as expected' do
      tokens = Emendate.prep_for('.1994', :collapse_tokens).tokens
      e = Editable.new(tokens)
      e.collapse_token_pair_forward(tokens[0], tokens[1])
      expect(e.result.type_string).to eq('number4')
    end
  end

  describe '#replace_x_with_new' do
    it 'tags as expected' do
      tokens = Emendate.prep_for('Jan 2021', :convert_months).tokens
      e = Editable.new(tokens)
      e.replace_x_with_new(x: tokens[0], new: tokens[1])
      expect(e.result.type_string).to eq('number4 number4')
    end
  end
end
