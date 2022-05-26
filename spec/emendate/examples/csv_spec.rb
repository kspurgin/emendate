# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::Examples::Csv do
  let(:klass){ described_class.new }
  
  describe '#retrieve_rows' do
    let(:result){ klass.retrieve_rows(str, opt) }

    context 'when more than one rows match' do
      let(:str){ 'a' }
      let(:opt){ 'aaa' }

      it 'returns rows as expected' do
        expect(result.length).to eq(3)
      end
    end

    context 'when one row matches' do
      let(:str){ 'b' }
      let(:opt){ nil }

      it 'returns rows as expected' do
        expect(result.length).to eq(1)
      end
    end

    context 'when no rows match' do
      let(:str){ 'nothingtoseehere' }
      let(:opt){ nil }

      it 'returns no rows as expected' do
        expect(result.length).to eq(0)
      end
    end
  end
end

