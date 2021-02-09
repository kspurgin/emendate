require 'spec_helper'

RSpec.describe Emendate::DatePartTagger do
  def tag(str, options = {})
    pm = Emendate.prep_for(str, :tag_date_parts, options)
    fs = Emendate::DatePartTagger.new(tokens: pm.tokens, options: pm.options)
    fs.tag.types
  end
  
  describe '#tag' do
    context '999' do
      it 'tags year' do
        result = tag('999')
        expect(result).to eq(%i[year])
      end
    end
    context '2020' do
      it 'tags year' do
        result = tag('2020')
        expect(result).to eq(%i[year])
      end
    end
    context 'March' do
      it 'tags month' do
        result = tag('March')
        expect(result).to eq(%i[month])
      end
    end
    context '1000s' do
      xit 'tags millennium' do
        result = tag('1000s')
        expect(result).to eq(%i[millennium])
      end
    end
    context '1900s' do
      it 'tags century' do
        result = tag('1900s')
        expect(result).to eq(%i[century])
      end
    end
    context '1990s' do
      it 'tags decade' do
        result = tag('1990s')
        expect(result).to eq(%i[decade])
      end
    end
    context '199X' do
      it 'tags decade' do
        result = tag('199X')
        expect(result).to eq(%i[decade])
      end
    end
    context '19th century' do
      it 'tags century' do
        result = tag('19th century')
        expect(result).to eq(%i[century])
      end
    end

    context 'February 15, 2020' do
      it 'tags day (month and year are already done at this point)' do
        result = tag('February 15, 2020')
        expect(result).to eq(%i[month day year])
      end
    end

    context 'February 30, 2020' do
      it 'returns error' do
        pm = Emendate.prep_for('February 30, 2020', :tag_date_parts)
        tagger = Emendate::DatePartTagger.new(tokens: pm.tokens)
        expect{ tagger.tag }.to raise_error(Emendate::DatePartTagger::UntaggableDatePartError)
      end
    end

    context '02-10-20' do
      context 'in the year 2020' do
      before(:each) do
        allow(Date).to receive(:today).and_return Date.new(2020,2,3)
        pm = Emendate.prep_for('02-10-20', :tag_date_parts)
        tagger = Emendate::DatePartTagger.new(tokens: pm.tokens, options: pm.options)
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

    context '02-03-2020' do
      context 'default' do
        it 'tags month day year' do
          result = tag('02-03-2020')
          expect(result).to eq(%i[month day year])
        end
      end
      context 'ambiguous_month_day: :as_day_month' do
        it 'tags day month year' do
          pm = Emendate.prep_for('02-03-2020', :tag_date_parts, ambiguous_month_day: :as_day_month)
          tagger = Emendate::DatePartTagger.new(tokens: pm.tokens, options: pm.options)
          expect(tagger.tag.types).to eq(%i[day month year])
        end
      end
    end

    context '2003-04' do
      context 'default (treat as year)' do
        it 'converts hyphen into range_indicator' do
          result = tag('2003-04')
          expect(result).to eq(%i[year range_indicator year])
        end
      end
      context 'ambiguous_month_year: as_month' do
        it 'removes hyphen ' do
          pm = Emendate.prep_for('2003-04', :tag_date_parts, ambiguous_month_year: :as_month)
          tagger = Emendate::DatePartTagger.new(tokens: pm.tokens, options: pm.options)
          expect(tagger.tag.type_string).to eq('year month')
        end
      end
    end

    context '2 December 2020, 2020/02/15' do
      it 'tags' do
        result = tag('2 December 2020, 2020/02/15')
        expect(result).to eq(%i[month day year comma year month day])
      end
    end
    
    context 'Mar 19' do
        it 'tags as month year' do
          pm = Emendate.prep_for('Mar 19', :tag_date_parts)
          tagger = Emendate::DatePartTagger.new(tokens: pm.tokens, options: pm.options)
          expect(tagger.tag.type_string).to eq('month year')
        end
      context 'default (coerce to 4-digit year)' do
        it 'converts year to 2019' do
          pm = Emendate.prep_for('Mar 19', :tag_date_parts)
          tagger = Emendate::DatePartTagger.new(tokens: pm.tokens, options: pm.options)
          expect(tagger.tag[1].literal).to eq(2019)
        end
      end
      context 'two_digit_year_handling: literal' do
        it 'leaves year as 19' do
          pm = Emendate.prep_for('Mar 19', :tag_date_parts, two_digit_year_handling: :literal)
          tagger = Emendate::DatePartTagger.new(tokens: pm.tokens, options: pm.options)
          expect(tagger.tag[1].literal).to eq(19)
        end
      end
    end
  end
end
