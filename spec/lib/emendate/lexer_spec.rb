require 'spec_helper'

RSpec.describe Emendate::Lexer do
  context 'unknown token' do
    it 'raises error' do
      orig = '@'
      expected = [:unknown]
      expect{ Emendate.lex(orig) }.to raise_error(Emendate::UntokenizableError)
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
    context 'single dot' do
      it 'produces expected tokens' do
        orig = 'Sep. 1'
        expected = %i[month_abbr_alpha number1or2]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end
    context 'double dot' do
      it 'produces expected tokens' do
        orig = '{..1984'
        expected = %i[curly_bracket_open double_dot number4]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end
    context 'multi dot' do
      it 'produces expected tokens' do
        orig = '{...1984'
        expected = %i[curly_bracket_open unknown number4]
        
        expect{ Emendate.lex(orig) }.to raise_error(Emendate::UntokenizableError)
      end
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
      orig = '1 22 333 4444'
      expected = [:number1or2, :number1or2, :number3, :number4]
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

    context 'special single letters' do
      it 'produces expected tokens' do
        # note: c isn't first in string or it'd get normalized to circa
        orig = 'e c s t y z'
        expected = %i[letter_e letter_c letter_s letter_t letter_y letter_z]
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

    context 'seasons' do
      it 'produces expected tokens' do
        orig = 'Spring Winter Fall'
        expected = [:season, :season, :season]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'edtf-specific punctuation' do
      it 'produces expected tokens' do
        orig = '+%~{}:'
        expected = %i[plus percent tilde curly_bracket_open curly_bracket_close colon]
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
  end
end
