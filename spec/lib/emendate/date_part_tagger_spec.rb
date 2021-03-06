# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DatePartTagger do
  def tag(str, options = {})
    pm = Emendate.prep_for(str, :tag_date_parts, options)
    fs = Emendate::DatePartTagger.new(tokens: pm.tokens, options: pm.options)
    fs.tag
  end

  describe '#tag' do
    context 'with 999' do
      it 'tags year' do
        result = tag('999')
        expect(result.types).to eq(%i[year])
      end
    end

    context 'with 2020' do
      it 'tags year' do
        result = tag('2020')
        expect(result.types).to eq(%i[year])
      end
    end

    context 'with March' do
      it 'tags month' do
        result = tag('March')
        expect(result.types).to eq(%i[month])
      end
    end

    context 'with 0000s 1000s' do
      context 'when default options' do
        before(:all){ @result = tag('0000s 1000s') }

        it 'tags decade' do
          expect(@result.types).to eq(%i[decade decade])
        end

        it 'generates warnings' do
          w = ['Interpreting pluralized year as decade', 'Interpreting pluralized year as decade']
          expect(w - @result.warnings).to be_empty
        end
      end

      context 'when pluralized_date_interpretation: :broad' do
        before(:all){ @result = tag('0000s 1000s', pluralized_date_interpretation: :broad) }

        it 'tags millennium' do
          expect(@result.types).to eq(%i[millennium millennium])
        end

        it 'generates warnings' do
          w = ['Interpreting pluralized year as millennium', 'Interpreting pluralized year as millennium']
          expect(w - @result.warnings).to be_empty
        end
      end
    end

    context 'with 1900s' do
      context 'when default options' do
        before(:all){ @result = tag('1900s') }

        it 'tags decade' do
          expect(@result.types).to eq(%i[decade])
        end

        it 'literal is whole number' do
          expect(@result[0].literal).to eq(1900)
        end
      end

      context 'when pluralized_date_interpretation: :broad' do
        before(:all){ @result = tag('1900s', pluralized_date_interpretation: :broad)}

        it 'tags century' do
          expect(@result.types).to eq(%i[century])
        end

        it 'literal is whole number' do
          expect(@result[0].literal).to eq(1900)
        end
      end
    end

    context 'with 1990s' do
      it 'tags decade' do
        result = tag('1990s')
        expect(result.types).to eq(%i[decade])
      end
    end

    context 'with 199X' do
      it 'tags decade' do
        result = tag('199X')
        expect(result.types).to eq(%i[decade])
      end
    end

    context 'with 19th century' do
      it 'tags century' do
        result = tag('19th century')
        expect(result.types).to eq(%i[century])
      end
    end

    context 'with 19uu' do
      it 'tags century' do
        result = tag('19uu')
        expect(result.types).to eq(%i[century])
      end
    end

    context 'with February 15, 2020' do
      it 'tags day (month and year are already done at this point)' do
        result = tag('February 15, 2020')
        expect(result.types).to eq(%i[month day year])
      end
    end

    context 'with February 30, 2020' do
      it 'returns error' do
        pm = Emendate.prep_for('February 30, 2020', :tag_date_parts)
        tagger = described_class.new(tokens: pm.tokens)
        expect{ tagger.tag }.to raise_error(Emendate::DatePartTagger::UntaggableDatePartError)
      end
    end

    context 'with 02-10-20' do
      context 'when in the year 2020' do
        before(:each) do
          allow(Date).to receive(:today).and_return Date.new(2020, 2, 3)
          pm = Emendate.prep_for('02-10-20', :tag_date_parts)
          tagger = described_class.new(tokens: pm.tokens, options: pm.options)
          @result = tagger.tag
        end

        it 'tags month, day, and short year' do
          expect(@result.type_string).to eq('month day year')
        end

        it 'expands/tags short year to 1920' do
          expect(@result.map(&:literal).join(' ')).to eq('2 10 1920')
        end
      end
    end

    context 'with 02-03-2020' do
      context 'when default options' do
        it 'tags month day year' do
          result = tag('02-03-2020')
          expect(result.types).to eq(%i[month day year])
        end
      end

      context 'when ambiguous_month_day: :as_day_month' do
        it 'tags day month year' do
          pm = Emendate.prep_for('02-03-2020', :tag_date_parts, ambiguous_month_day: :as_day_month)
          tagger = described_class.new(tokens: pm.tokens, options: pm.options)
          expect(tagger.tag.types).to eq(%i[day month year])
        end
      end
    end

    context 'with 2003-04' do
      context 'when default options (treat as year)' do
        it 'converts hyphen into range_indicator' do
          result = tag('2003-04')
          expect(result.types).to eq(%i[year range_indicator year])
        end
      end

      context 'when ambiguous_month_year: as_month' do
        it 'removes hyphen ' do
          pm = Emendate.prep_for('2003-04', :tag_date_parts, ambiguous_month_year: :as_month)
          tagger = described_class.new(tokens: pm.tokens, options: pm.options)
          expect(tagger.tag.type_string).to eq('year month')
        end
      end
    end

    context 'with 2 December 2020, 2020/02/15' do
      it 'tags' do
        result = tag('2 December 2020, 2020/02/15')
        expect(result.types).to eq(%i[month day year comma year month day])
      end
    end

    context 'with 2004-06/2006-08' do
      context 'when default options' do
        it 'tags' do
          result = tag('2004-06/2006-08')
          expect(result.type_string).to eq('year month range_indicator year month')
        end
      end
    end

    context 'with Mar 19' do
        it 'tags as month year' do
          pm = Emendate.prep_for('Mar 19', :tag_date_parts)
          tagger = described_class.new(tokens: pm.tokens, options: pm.options)
          expect(tagger.tag.type_string).to eq('month year')
        end

        context 'when default options (coerce to 4-digit year)' do
          it 'converts year to 2019' do
            pm = Emendate.prep_for('Mar 19', :tag_date_parts)
            tagger = described_class.new(tokens: pm.tokens, options: pm.options)
            expect(tagger.tag[1].literal).to eq(2019)
          end
        end

        context 'when two_digit_year_handling: literal' do
          it 'leaves year as 19' do
            pm = Emendate.prep_for('Mar 19', :tag_date_parts, two_digit_year_handling: :literal)
            tagger = described_class.new(tokens: pm.tokens, options: pm.options)
            expect(tagger.tag[1].literal).to eq(19)
          end
        end
    end
  end
end
