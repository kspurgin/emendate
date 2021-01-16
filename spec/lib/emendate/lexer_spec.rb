require 'spec_helper'

RSpec.describe Emendate::Lexer do
  describe '#start_tokenization' do
    context 'unknown token' do
      it 'raises error' do
        orig = '%'
        expected = [:unknown, :eof]
        lexer = Emendate::Lexer.new(orig)
        lexer.start_tokenization
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end
    
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
        orig = '1 22 333 4444 55555'
        expected = [:number, :number, :number, :number, :unknown, :eof]
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
          orig = 's'
          expected = [:s, :eof]
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
        it 'unknown produces expected tokens' do
          orig = 'unknown'
          expected = [:unknown_date, :eof]
          lexer = Emendate::Lexer.new(orig)
          lexer.start_tokenization
          expect(lexer.tokens.map(&:type)).to eq(expected)
        end
        it 'n.d. produces expected tokens' do
          orig = 'n.d.'
          expected = [:unknown_date, :eof]
          lexer = Emendate::Lexer.new(orig)
          lexer.start_tokenization
          expect(lexer.tokens.map(&:type)).to eq(expected)
        end
        it 'n. d. produces expected tokens' do
          orig = 'n. d.'
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

      context 'early/late/mid' do
        it 'produces expected tokens' do
          orig = 'early late middle mid'
          expected = [:early, :late, :middle, :middle, :eof]
          lexer = Emendate::Lexer.new(orig)
          lexer.start_tokenization
          expect(lexer.tokens.map(&:type)).to eq(expected)
        end
      end

      context 'before/after' do
        it 'produces expected tokens' do
          orig = 'before pre after post'
          expected = [:before, :before, :after, :after, :eof]
          lexer = Emendate::Lexer.new(orig)
          lexer.start_tokenization
          expect(lexer.tokens.map(&:type)).to eq(expected)
        end
      end

      context 'and' do
        it 'produces expected tokens' do
          orig = '& and'
          expected = [:and, :and, :eof]
          lexer = Emendate::Lexer.new(orig)
          lexer.start_tokenization
          expect(lexer.tokens.map(&:type)).to eq(expected)
        end
      end

      context 'range indicator' do
        it 'produces expected tokens' do
          orig = 'to'
          expected = [:range_indicator, :eof]
          lexer = Emendate::Lexer.new(orig)
          lexer.start_tokenization
          expect(lexer.tokens.map(&:type)).to eq(expected)
        end
      end

      context 'unknown alpha string' do
        it 'produces expected tokens' do
          orig = 'somethingweird'
          expected = [:unknown, :eof]
          lexer = Emendate::Lexer.new(orig)
          lexer.start_tokenization
          expect(lexer.tokens.map(&:type)).to eq(expected)
        end
      end
    end
  end
end
