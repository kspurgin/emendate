require 'spec_helper'

RSpec.describe Emendate::Lexer do
  context 'unknown token' do
    it 'raises error' do
      orig = '%'
      expected = [:unknown]
      lexer = Emendate.lex(orig)
      expect(lexer.tokens.map(&:type)).to eq(expected)
    end
  end
  
  context 'comma' do
    it 'produces expected tokens' do
      orig = ','
      expected = [:comma]
      lexer = Emendate.lex(orig)
      expect(lexer.tokens.map(&:type)).to eq(expected)
    end
  end

  context 'dot' do
    it 'produces expected tokens' do
      orig = '.'
      expected = []
      lexer = Emendate.lex(orig)
      expect(lexer.tokens.map(&:type)).to eq(expected)
    end
  end

  context 'hyphen' do
    it 'produces expected tokens' do
      orig = '- –'
      expected = [:hyphen, :hyphen]
      lexer = Emendate.lex(orig)
      expect(lexer.tokens.map(&:type)).to eq(expected)
    end
  end

  context 'question' do
    it 'produces expected tokens' do
      orig = '?'
      expected = [:question]
      lexer = Emendate.lex(orig)
      expect(lexer.tokens.map(&:type)).to eq(expected)
    end
  end
  
  context 'slash' do
    it 'produces expected tokens' do
      orig = '/'
      expected = [:slash]
      lexer = Emendate.lex(orig)
      expect(lexer.tokens.map(&:type)).to eq(expected)
    end
  end

  context 'square brackets' do
    it 'produces expected tokens' do
      orig = '[]'
      expected = [:square_bracket_open, :square_bracket_close]
      lexer = Emendate.lex(orig)
      expect(lexer.tokens.map(&:type)).to eq(expected)
    end
  end

  context 'numbers' do
    it 'produces expected tokens' do
      orig = '1 22 333 4444 55555'
      expected = [:number1or2, :number1or2, :number3, :number4, :unknown]
      lexer = Emendate.lex(orig)
      expect(lexer.tokens.map(&:type)).to eq(expected)
    end
  end

  context 'alpha string types' do
    context 'ordinal' do
      it 'produces expected tokens' do
        orig = 'th'
        expected = [:ordinal_indicator]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'alpha month' do
      it 'produces expected tokens' do
        orig = 'August Jan'
        expected = [:month_alpha, :month_abbr_alpha]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'alpha day of week' do
      it 'produces expected tokens' do
        orig = 'Mon Tuesday'
        expected = [:day_of_week_alpha, :day_of_week_alpha]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'uncertainty digits -- letters in place of numbers to indicate uncertainty' do
      it 'produces expected tokens' do
        orig = 'x xx uuu'
        expected = [:uncertainty_digits, :uncertainty_digits, :uncertainty_digits]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 's' do
      it 'produces expected tokens' do
        orig = 's'
        expected = [:s]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'century' do
      it 'produces expected tokens' do
        orig = 'cent century'
        expected = [:century, :century]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'circa' do
      it 'produces expected tokens' do
        orig = 'c ca circa'
        expected = [:approximate, :approximate, :approximate]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'unknown date' do
      it 'unknown produces expected tokens' do
        orig = 'unknown'
        expected = [:unknown_date]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
      it 'n.d. produces expected tokens' do
        orig = 'n.d.'
        expected = [:unknown_date]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
      it 'n. d. produces expected tokens' do
        orig = 'n. d.'
        expected = [:unknown_date]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'or (alternate date indicator)' do
      it 'produces expected tokens' do
        orig = 'or'
        expected = [:or]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'eras' do
      before(:all) do
        orig = 'b.c.e  bp c.e.'
        @lexer = Emendate.lex(orig)
      end
      it 'produces expected token types' do
        expected = [:era, :era, :era]
        expect(@lexer.tokens.types).to eq(expected)
      end
    end

    context 'early/late/mid' do
      it 'produces expected tokens' do
        orig = 'early late middle mid'
        expected = [:partial, :partial, :partial, :partial]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'before/after' do
      it 'produces expected tokens' do
        orig = 'before pre after post'
        expected = [:before, :before, :after, :after]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'and' do
      it 'produces expected tokens' do
        orig = '& and'
        expected = [:and, :and]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'range indicator' do
      it 'produces expected tokens' do
        orig = 'to'
        expected = [:range_indicator]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'unknown alpha string' do
      it 'produces expected tokens' do
        orig = 'somethingweird'
        expected = [:unknown]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end
  end
end
