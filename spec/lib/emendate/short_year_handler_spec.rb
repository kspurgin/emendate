# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::ShortYearHandler do
  def prep(str, options = {})
    options = Emendate::Options.new(options)
    t = Emendate::Token.new(type: :stub,
                            lexeme: str,
                            literal: str.to_i)
    syh = Emendate::ShortYearHandler.new(t, options)
    syh.result.literal
  end

  context 'when default options' do
    context 'with ambiguous year: 21' do
      context 'when current year is 2021' do
        before{ allow(Date).to receive(:today).and_return Date.new(2021,2,3) }

        it 'coerced to 1921' do
          expect(prep('21')).to eq(1921)
        end
      end

      context 'when current year is 2022' do
        before{ allow(Date).to receive(:today).and_return Date.new(2022,2,3) }

        it 'coerced to 2021' do
          expect(prep('21')).to eq(2021)
        end
      end
    end
  end

  context 'when two_digit_year_handling: :literal' do
    context 'with ambiguous year: 21' do
      it 'left as 21' do
          expect(prep('21', two_digit_year_handling: :literal)).to eq(21)
        end
      end
  end

  context 'when ambiguous_year_rollback_threshold: 10' do
    context 'with ambiguous year: 08' do
      context 'when current year is 2011' do
        before{ allow(Date).to receive(:today).and_return Date.new(2011,2,3) }

        it 'coerced to 2008' do
          expect(prep('08')).to eq(2008)
        end
      end

      context 'when current year is 2006' do
        before{ allow(Date).to receive(:today).and_return Date.new(2006,2,3) }

        it 'coerced to 1908' do
          expect(prep('08')).to eq(1908)
        end
      end
    end
  end
end

