# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::ShortYearHandler do
  let(:str){ '21' }
  let(:token){ Emendate::Token.new(type: :stub, lexeme: str, literal: str.to_i) }
  let(:result) do
    Emendate::Options.new(opts)
    Emendate::ShortYearHandler.call(token).literal
  end

  context 'with two_digit_year_handling: :coerce and ambiguous year: 21' do
    let(:ayrt){ Date.today.year.to_s[-2..-1].to_i }
    let(:opts){ {two_digit_year_handling: :coerce, ambiguous_year_rollback_threshold: ayrt} }
    
    context 'when current year is 2020 (value > threshold)' do
      before{ allow(Date).to receive(:today).and_return Date.new(2020, 2, 3) }

      it 'coerced to 1921' do
        expect(result).to eq(1921)
      end
    end

    context 'when current year is 2021 (value = threshold)' do
      before{ allow(Date).to receive(:today).and_return Date.new(2021, 2, 3) }

      it 'coerced to 1921' do
        expect(result).to eq(1921)
      end
    end

    context 'when current year is 2022 (value < threshold)' do
      before{ allow(Date).to receive(:today).and_return Date.new(2022, 2, 3) }

      it 'coerced to 2021' do
        expect(result).to eq(2021)
      end
    end
  end


  context 'when two_digit_year_handling: :literal' do
    let(:opts){ {two_digit_year_handling: :literal} }
    context 'with ambiguous year: 21' do
      it 'left as 21' do
        expect(result).to eq(21)
      end
    end
  end
end

