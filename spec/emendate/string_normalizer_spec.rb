# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::StringNormalizer do
  subject(:normalizer){ described_class }

  describe '.call' do
    it 'returns expected tokens' do
      examples = {
        'c1981'=>'circa1981'
      }

      results = examples.keys
        .map{ |str|
          [
            str,
            normalizer.call(str)
              .value!
              .norm
          ]
        }.to_h
      expect(results).to eq examples
    end
  end
end
