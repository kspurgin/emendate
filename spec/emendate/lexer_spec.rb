# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::Lexer do
  subject(:lexer){ described_class }

  describe '.call' do
    it 'returns expected tokens' do
      examples = {
        '@'=>[:unknown],
        ','=>[:comma],
        'Sep. 1'=>%i[month_abbr_alpha single_dot space number1or2],
        '{..1984'=>%i[curly_bracket_open double_dot number4],
        '{...1984'=>%i[curly_bracket_open unknown number4],
        '- –'=>%i[hyphen space hyphen],
        '?'=>[:question],
        '/'=>[:slash],
        '[]'=>%i[square_bracket_open square_bracket_close],
        '1 22 333 4444'=>%i[number1or2 space number1or2 space number3 space
                            number4],
        '4444.0'=>%i[number4 single_dot standalone_zero],
        'th'=>[:ordinal_indicator],
        'August Jan'=>%i[month_alpha space month_abbr_alpha],
        'Mon Tuesday'=>%i[day_of_week_alpha space day_of_week_alpha],
        'x xx uuu'=>%i[uncertainty_digits space uncertainty_digits space
                       uncertainty_digits],
        # note: c isn't first in string or it'd get normalized to circa
        'e c s t y z'=>%i[letter_e space letter_c space letter_s space letter_t
                          space letter_y space letter_z],
        'cent century'=>%i[century space century],
        'c ca circa approximately around'=>%i[approximate space approximate
                                              space approximate space
                                              approximate space approximate],
        'unknown'=>[:unknown_date],
        'n.d.'=>[:unknown_date],
        'n. d.'=>[:unknown_date],
        'or'=>[:or],
        'b.c.e bp c.e.'=>%i[era space era space era],
        'early late middle mid'=>%i[partial space partial space partial space
                                    partial],
        'before pre after post'=>%i[before space before space after space
                                    after],
        '& and'=>%i[and space and],
        'Spring Winter Fall'=>%i[season space season space season],
        '+%~{}:'=>%i[plus percent tilde curly_bracket_open curly_bracket_close
                     colon],
        'to'=>[:range_indicator]
      }.transform_keys!{ |key| Emendate.normalize(key).value!}

      results = examples.keys
        .map do |str|
          [
            str,
            lexer.call(str)
              .value!
              .tokens
              .map(&:type)
          ]
        end
        .to_h
      expect(results).to eq examples
    end
  end
end
