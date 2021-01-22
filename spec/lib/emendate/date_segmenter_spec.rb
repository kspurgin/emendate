require 'spec_helper'

RSpec.describe Emendate::DateSegmenter do
  describe '#segmentation' do
    before(:all) do
      @l = Emendate.lex('2021-01')
    end
    it 'testing' do
      s = Emendate::DateSegmenter.new(tokens: @l.tokens)
      s.segmentation
    end
  end
end
