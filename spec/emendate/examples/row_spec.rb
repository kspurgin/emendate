# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::Examples::Row do
  let(:opt){ nil }
  let(:klass){ test_rows(str, opt).first }
  
  describe '#runnable_tests' do
    let(:result){ klass.runnable_tests }

    context 'with c/nil' do
      let(:str){ 'c' }

      it 'returns as expected' do
        expect(result).to eq(Emendate.examples.tests)
      end
    end

    context 'with b/nil' do
      let(:str){ 'b' }

      it 'returns as expected' do
        expected = Emendate.examples.tests - %w[date_start_full]
        expect(result).to eq(expected)
      end
    end

  end
end

