# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::Examples::TestableExample do
  let(:opt){ nil }
  let(:rows){ test_rows(str, opt) }
  let(:klass){ described_class.new(rows) }

  context 'with no rows' do
    let(:str){ 'nomatchingstrings' }

    it 'raises error' do
      expect{ klass }.to raise_error(Emendate::Examples::TestableExample::EmptyTestSetError)
    end
  end
  
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

    context 'with a/aaa' do
      let(:str){ 'a' }
      let(:opt){ 'aaa' }

      it 'returns as expected' do
        expected = Emendate.examples.tests - %w[date_start_full translation_lyrasis_pseudo_edtf]
        expect(result).to eq(expected)
      end
    end
  end

  describe '#testable?' do
    let(:result){ klass.testable? }

    context 'with bad options' do 
      let(:str){ '2002' }
      let(:opt){ 'unknown_opt: :foo' }

      it 'returns as expected', :aggregate_failures do
        expect(result).to eq(false)
        expect(klass.errors.length).to eq(1)
        expect(klass.errors.key?(:process)).to be true
      end
    end

    context 'with 2002/nil' do
      let(:str){ '2002' }

      it 'returns as expected', :aggregate_failures do
        expect(result).to eq(true)
        expect(klass.processed).to be_a(Emendate::Result)
      end
    end
  end

end

