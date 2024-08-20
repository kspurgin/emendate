# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::Lexer do
  subject(:lexer) { described_class }

  describe ".call" do
    it "returns expected tokens" do
      examples = {
        "c." => [:approximate],
        "c 1947" => %i[approximate number4],
        "© 1947" => %i[copyright space number4],
        "(C) 1947" => %i[parenthesis_open letter_c parenthesis_close space
          number4],
        "2nd" => %i[number1or2 ordinal_indicator],
        "3d" => %i[number1or2 letter_d],
        "c1947" => %i[approximate number4],
        "1919 andor 1950" => %i[number4 space unknown space number4],
        "@" => [:unknown],
        "Sep. 1" => %i[month space number1or2],
        "cat" => [:unknown],
        "Sept. 19, 1918" => %i[month space number1or2 comma space
          number4],
        "Sep. 19, 1918" => %i[month space number1or2 comma space
          number4],
        "September 19, 1918" => %i[month space number1or2 comma space
          number4],
        "{..1984" => %i[curly_bracket_open double_dot number4],
        "{...1984" => %i[curly_bracket_open unknown number4],
        "- –" => %i[hyphen space hyphen],
        "1---" => %i[number1or2 uncertainty_digits],
        "19--" => %i[number1or2 uncertainty_digits],
        "19--200" => %i[number1or2 uncertainty_digits hyphen number3],
        "19---" => %i[number1or2 uncertainty_digits hyphen],
        "19---2003" => %i[number1or2 uncertainty_digits hyphen number4],
        "199-?" => %i[number3 uncertainty_digits question],
        "199-200" => %i[number3 hyphen number3],
        "1999-" => %i[number4 hyphen],
        "?" => [:question],
        "/" => [:slash],
        "[]" => %i[square_bracket_open square_bracket_close],
        "1 22 333 4444" => %i[number1or2 space number1or2 space number3 space
          number4],
        "4444.0" => %i[number4 single_dot standalone_zero],
        "August Jan" => %i[month space month],
        "Mon Tuesday" => %i[day_of_week_alpha space day_of_week_alpha],
        "x xx uuu" => %i[uncertainty_digits space uncertainty_digits space
          uncertainty_digits],
        # # NOTE: c isn't first in string or it'd get normalized to approximate
        "e c s t y z" => %i[letter_e space letter_c space letter_s space
          letter_t space letter_y space letter_z],
        "cent century" => %i[century space century],
        "approximate around" => %i[approximate space approximate],
        "approximately estimated" => %i[approximate space approximate],
        "c ca approximate" => %i[approximate approximate space approximate],
        "unknown" => [:unknown_date],
        "unkn" => [:unknown_date],
        "unk." => %i[unknown_date single_dot],
        "n.d." => [:no_date],
        "n. d." => [:no_date],
        "or" => [:or],
        "b.c.e bp c.e. a.d." => %i[era_bce space era_bce space era_ce space
          era_ce],
        "early late middle mid" => %i[partial space partial space partial space
          partial],
        "before pre after post" => %i[before space before space after space
          after],
        "& and" => %i[and space and],
        "Spring Winter Fall" => %i[season space season space season],
        "+%~{}:" => %i[plus percent tilde curly_bracket_open curly_bracket_close
          colon],
        "to" => [:range_indicator],
        "1974-present" => %i[number4 hyphen present],
        "1985-04-12T23:20:30" => %i[number4 hyphen number1or2 hyphen number1or2
          letter_t
          number1or2 colon number1or2 colon
          number1or2],
        "early 19th c." => %i[partial space number1or2 ordinal_indicator space
          letter_c single_dot],
        "n.d., before 1955" => %i[no_date comma space before space
          number4],
        "1979｜1980 Jan" => %i[number4 pipe number4 space month],
        "1979|1980 Jan" => %i[number4 pipe number4 space month],
        "date of publication not identified" => %i[no_date]
      }

      results = examples.keys
        .map do |str|
          tokens = Emendate::SegmentSet.new(string: str)
          [
            str,
            lexer.call(tokens)
              .either(->(s) { s }, ->(f) { f })
              .map(&:type)
          ]
        end
        .to_h
      expect(results).to eq examples
    end

    context "with c_before_date = copyright" do
      before do
        Emendate.config.options.c_before_date = :copyright
      end

      it "returns expected tokens" do
        examples = {
          "c." => [:copyright],
          "c 1947" => %i[copyright number4],
          "c1947" => %i[copyright number4],
          "early 19th c." => %i[partial space number1or2 ordinal_indicator space
            letter_c single_dot]
        }

        results = examples.keys
          .map do |str|
            tokens = Emendate::SegmentSet.new(string: str)
            [
              str,
              lexer.call(tokens)
                .either(->(s) { s }, ->(f) { f })
                .map(&:type)
            ]
          end
          .to_h
        expect(results).to eq examples
      end
    end
  end
end
