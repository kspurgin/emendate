
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::OldLexer do
  context 'with unknown token' do
    it 'produces expected tokens' do
      orig = '@'
      expected = [:unknown]
      lexer = Emendate.lex(orig)
      expect(lexer.tokens.map(&:type)).to eq(expected)
    end
  end

  context 'with comma' do
    it 'produces expected tokens' do
      orig = ','
      expected = [:comma]
      lexer = Emendate.lex(orig)
      expect(lexer.tokens.map(&:type)).to eq(expected)
    end
  end

  context 'with dot' do
    context 'with single dot' do
      it 'produces expected tokens' do
        orig = 'Sep. 1'
        expected = %i[month_abbr_alpha single_dot space number1or2]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'with double dot' do
      it 'produces expected tokens' do
        orig = '{..1984'
        expected = %i[curly_bracket_open double_dot number4]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'with multi dot' do
      it 'produces expected tokens' do
        orig = '{...1984'
        expected = %i[curly_bracket_open unknown number4]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end
  end

  context 'with hyphen' do
    it 'produces expected tokens' do
      orig = '- –'
      expected = %i[hyphen space hyphen]
      lexer = Emendate.lex(orig)
      expect(lexer.tokens.map(&:type)).to eq(expected)
    end
  end

  context 'with question' do
    it 'produces expected tokens' do
      orig = '?'
      expected = [:question]
      lexer = Emendate.lex(orig)
      expect(lexer.tokens.map(&:type)).to eq(expected)
    end
  end

  context 'with slash' do
    it 'produces expected tokens' do
      orig = '/'
      expected = [:slash]
      lexer = Emendate.lex(orig)
      expect(lexer.tokens.map(&:type)).to eq(expected)
    end
  end

  context 'with square brackets' do
    it 'produces expected tokens' do
      orig = '[]'
      expected = %i[square_bracket_open square_bracket_close]
      lexer = Emendate.lex(orig)
      expect(lexer.tokens.map(&:type)).to eq(expected)
    end
  end

  context 'with numbers' do
    it 'produces expected tokens' do
      orig = '1 22 333 4444'
      expected = %i[number1or2 space number1or2 space number3 space number4]
      lexer = Emendate.lex(orig)
      expect(lexer.tokens.map(&:type)).to eq(expected)
    end
  end

  context 'with standalone zero' do
    it 'produces expected tokens' do
      orig = '4444.0'
      expected = %i[number4 single_dot standalone_zero]
      lexer = Emendate.lex(orig)
      expect(lexer.tokens.map(&:type)).to eq(expected)
    end
  end

  context 'with alpha string types' do
    context 'with ordinal' do
      it 'produces expected tokens' do
        orig = 'th'
        expected = [:ordinal_indicator]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'with alpha month' do
      it 'produces expected tokens' do
        orig = 'August Jan'
        expected = %i[month_alpha space month_abbr_alpha]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'with alpha day of week' do
      it 'produces expected tokens' do
        orig = 'Mon Tuesday'
        expected = %i[day_of_week_alpha space day_of_week_alpha]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'with uncertainty digits -- letters in place of numbers to indicate uncertainty' do
      it 'produces expected tokens' do
        orig = 'x xx uuu'
        expected = %i[uncertainty_digits space uncertainty_digits space uncertainty_digits]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'with special single letters' do
      it 'produces expected tokens' do
        # note: c isn't first in string or it'd get normalized to circa
        orig = 'e c s t y z'
        expected = %i[letter_e space letter_c space letter_s space letter_t space letter_y space letter_z]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'with century' do
      it 'produces expected tokens' do
        orig = 'cent century'
        expected = %i[century space century]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'with circa' do
      it 'produces expected tokens' do
        orig = 'c ca circa approximately around'
        expected = %i[approximate space approximate space approximate space approximate space approximate]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'with unknown date' do
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

    context 'with or (alternate date indicator)' do
      it 'produces expected tokens' do
        orig = 'or'
        expected = [:or]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'with eras' do
      before(:all) do
        orig = 'b.c.e bp c.e.'
        @lexer = Emendate.lex(orig)
      end

      it 'produces expected token types' do
        expected = %i[era space era space era]
        expect(@lexer.tokens.types).to eq(expected)
      end
    end

    context 'with early/late/mid' do
      it 'produces expected tokens' do
        orig = 'early late middle mid'
        expected = %i[partial space partial space partial space partial]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'with before/after' do
      it 'produces expected tokens' do
        orig = 'before pre after post'
        expected = %i[before space before space after space after]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'with and' do
      it 'produces expected tokens' do
        orig = '& and'
        expected = %i[and space and]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'with seasons' do
      it 'produces expected tokens' do
        orig = 'Spring Winter Fall'
        expected = %i[season space season space season]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'with edtf-specific punctuation' do
      it 'produces expected tokens' do
        orig = '+%~{}:'
        expected = %i[plus percent tilde curly_bracket_open curly_bracket_close colon]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end

    context 'with range indicator' do
      it 'produces expected tokens' do
        orig = 'to'
        expected = [:range_indicator]
        lexer = Emendate.lex(orig)
        expect(lexer.tokens.map(&:type)).to eq(expected)
      end
    end
  end
end
