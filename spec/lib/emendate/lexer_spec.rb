require 'spec_helper'

RSpec.describe Emendate::Lexer do
  describe '#start_tokenization' do
    context 'comma' do
      it 'produces expected tokens' do
        orig = ','
        expected = [:comma, :eof]
        lexer = Emendate::Lexer.new(orig)
        lexer.start_tokenization
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'dot' do
      it 'produces expected tokens' do
        orig = '.'
        expected = [:eof]
        lexer = Emendate::Lexer.new(orig)
        lexer.start_tokenization
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'hyphen' do
      it 'produces expected tokens' do
        orig = '- –'
        expected = [:hyphen, :hyphen, :eof]
        lexer = Emendate::Lexer.new(orig)
        lexer.start_tokenization
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'question' do
      it 'produces expected tokens' do
        orig = '?'
        expected = [:question, :eof]
        lexer = Emendate::Lexer.new(orig)
        lexer.start_tokenization
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end
    
    context 'slash' do
      it 'produces expected tokens' do
        orig = '/'
        expected = [:slash, :eof]
        lexer = Emendate::Lexer.new(orig)
        lexer.start_tokenization
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'square brackets' do
      it 'produces expected tokens' do
        orig = '[]'
        expected = [:square_bracket_open, :square_bracket_close, :eof]
        lexer = Emendate::Lexer.new(orig)
        lexer.start_tokenization
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'numbers' do
      it 'produces expected tokens' do
        orig = '1 22 333 4444'
        expected = [:number_1_digit, :number_2_digit, :number_3_digit, :number_4_digit, :eof]
        lexer = Emendate::Lexer.new(orig)
        lexer.start_tokenization
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'alpha string types' do
      context 'ordinal' do
        it 'produces expected tokens' do
          orig = 'th'
          expected = [:ordinal_indicator, :eof]
          lexer = Emendate::Lexer.new(orig)
          lexer.start_tokenization
          expect(lexer.tokens.map(&:type)).to eq(expected)
        end
      end

      context 'alpha month' do
        it 'produces expected tokens' do
          orig = 'August Jan'
          expected = [:month_alpha, :month_alpha, :eof]
          lexer = Emendate::Lexer.new(orig)
          lexer.start_tokenization
          expect(lexer.tokens.map(&:type)).to eq(expected)
        end
      end

      context 'alpha day of week' do
        it 'produces expected tokens' do
          orig = 'Mon Tuesday'
          expected = [:day_of_week_alpha, :day_of_week_alpha, :eof]
          lexer = Emendate::Lexer.new(orig)
          lexer.start_tokenization
          expect(lexer.tokens.map(&:type)).to eq(expected)
        end
      end

      context 'uncertainty digits -- letters in place of numbers to indicate uncertainty' do
        it 'produces expected tokens' do
          orig = 'x xx uuu'
          expected = [:uncertainty_digits, :uncertainty_digits, :uncertainty_digits, :eof]
          lexer = Emendate::Lexer.new(orig)
          lexer.start_tokenization
          expect(lexer.tokens.map(&:type)).to eq(expected)
        end
      end

      context 's' do
        it 'produces expected tokens' do
          orig = 's ss'
          expected = [:s, :unknown_letters, :eof]
          lexer = Emendate::Lexer.new(orig)
          lexer.start_tokenization
          expect(lexer.tokens.map(&:type)).to eq(expected)
        end
      end

      context 'c' do
        # before date, indicates circa/approximate
        # after, indicates century
        it 'produces expected tokens' do
          orig = 'c'
          expected = [:c, :eof]
          lexer = Emendate::Lexer.new(orig)
          lexer.start_tokenization
          expect(lexer.tokens.map(&:type)).to eq(expected)
        end
      end

      context 'century' do
        it 'produces expected tokens' do
          orig = 'cent century'
          expected = [:century, :century, :eof]
          lexer = Emendate::Lexer.new(orig)
          lexer.start_tokenization
          expect(lexer.tokens.map(&:type)).to eq(expected)
        end
      end

      context 'circa' do
        it 'produces expected tokens' do
          orig = 'ca circa'
          expected = [:approximate, :approximate, :eof]
          lexer = Emendate::Lexer.new(orig)
          lexer.start_tokenization
          expect(lexer.tokens.map(&:type)).to eq(expected)
        end
      end

      context 'unknown date' do
        it 'produces expected tokens' do
          orig = 'unknown'
          expected = [:unknown_date, :eof]
          lexer = Emendate::Lexer.new(orig)
          lexer.start_tokenization
          expect(lexer.tokens.map(&:type)).to eq(expected)
        end
      end

      context 'unknown date (n.d.)' do
        it 'produces expected tokens' do
          orig = 'n.d.'
          expected = [:unknown_date, :eof]
          lexer = Emendate::Lexer.new(orig)
          lexer.start_tokenization
          expect(lexer.tokens.map(&:type)).to eq(expected)
        end
      end

      context 'or (alternate date indicator)' do
        it 'produces expected tokens' do
          orig = 'or'
          expected = [:or, :eof]
          lexer = Emendate::Lexer.new(orig)
          lexer.start_tokenization
          expect(lexer.tokens.map(&:type)).to eq(expected)
        end
      end

      context 'eras' do
        it 'produces expected tokens' do
          orig = 'b.c.e  bp c.e.'
          expected = [:bce, :bp, :ce, :eof]
          lexer = Emendate::Lexer.new(orig)
          lexer.start_tokenization
          expect(lexer.tokens.map(&:type)).to eq(expected)
        end
      end
    end
  end
end
