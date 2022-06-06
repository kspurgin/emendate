# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DatePartTagger do
  subject(:tagger){ described_class.new(tokens: tokens) }
  let(:tokens){ Emendate.prep_for(str, :tag_date_parts, options).tokens }
  let(:options){ {} }
  
  describe '#tag' do
    let(:result){ tagger.tag }
    let(:types){ result.types }
    
    context 'with 999' do
      let(:str){ '999' }
      it 'tags year' do
        expect(types).to eq(%i[year])
      end
    end

    context 'with 2020' do
      let(:str){ '2020' }
      
      it 'tags year' do
        expect(types).to eq(%i[year])
      end
    end

    context 'with 2020.0' do
      let(:str){ '2020.0' }
      
      it 'tags year' do
        expect(types).to eq(%i[year])
      end
    end

    context 'with March' do
      let(:str){ 'March' }
      
      it 'tags month' do
        expect(types).to eq(%i[month])
      end
    end

    context 'with 0000s 1000s' do
      let(:str){ '0000s 1000s' }
      
      context 'with default options' do
        it 'tags decade and warns of ambiguity' do
          expect(types).to eq(%i[decade decade])
          w = ['Interpreting pluralized year as decade', 'Interpreting pluralized year as decade']
          expect(w - result.warnings).to be_empty
        end
      end

      context 'when pluralized_date_interpretation: :broad' do
        let(:options){ {pluralized_date_interpretation: :broad} }

        it 'tags millennium and warns of ambiguity' do
          expect(types).to eq(%i[millennium millennium])
          w = ['Interpreting pluralized year as millennium', 'Interpreting pluralized year as millennium']
          expect(w - result.warnings).to be_empty
        end
      end
    end

    context 'with 1900s' do
      let(:str){ '1900s' }

      context 'when default options' do
        it 'tags decade' do
          expect(types).to eq(%i[decade])
          expect(result[0].literal).to eq(1900)
        end
      end

      context 'when pluralized_date_interpretation: :broad' do
        let(:options){ {pluralized_date_interpretation: :broad} }

        it 'tags century' do
          expect(types).to eq(%i[century])
          expect(result[0].literal).to eq(1900)
        end
      end
    end

    context 'with 1990s' do
      let(:str){ '1990s' }

      it 'tags decade' do
        expect(types).to eq(%i[decade])
      end
    end

    context 'with 19th century' do
      let(:str){ '19th century' }
      
      it 'tags century' do
        expect(types).to eq(%i[century])
      end
    end

    context 'with 19uu' do
      let(:str){ '19uu' }
      
      it 'tags century' do
        expect(types).to eq(%i[century])
      end
    end

    context 'with February 15, 2020' do
      let(:str){ 'February 15, 2020' }

      it 'tags day (month and year are already done at this point)' do
        expect(types).to eq(%i[month day year])
      end
    end

    context 'with 03/2020' do
      let(:str){ '03/2020' }
      
      it 'tags as expected' do
        expect(types).to eq(%i[month year])
      end
    end

    context 'with February 30, 2020' do
      let(:str){ 'February 30, 2020' }
      
      it 'returns error' do
        expect{ result }.to raise_error(Emendate::DatePartTagger::UntaggableDatePartError)
      end
    end

    context 'with "Oct. 28, 1964"' do
      let(:str){ 'Oct. 28, 1964' }
      
      it 'tags as expected' do
        expect(types).to eq(%i[month day year])
      end
    end

    context 'with 2-10-20 and current year is 2020' do
      before{ allow(Date).to receive(:today).and_return Date.new(2020, 2, 3) }
      let(:str){ '2-10-20' }
      let(:options){ {ambiguous_year_rollback_threshold: 20} }
      
      it 'tags month (2), day (10), and short year (1920)' do
        expect(types).to eq(%i[yearmonthday_date_type])
        expect(result.first.year).to eq(1920)
        expect(result.first.month).to eq(2)
        expect(result.first.day).to eq(10)
      end
    end

    context 'with 02-03-2020' do
      let(:str){ '02-03-2020' }
      
      context 'when default options' do
        it 'tags month day year' do
          expect(types).to eq(%i[month day year])
        end
      end

      context 'when ambiguous_month_day: :as_day_month' do
        let(:options){ {ambiguous_month_day: :as_day_month} }
        
        it 'tags day month year' do
          expect(types).to eq(%i[day month year])
        end
      end
    end

    context 'with 2003-04' do
      let(:str){ '2003-04' }
      
      context 'when default options (treat as year)' do
        it 'converts hyphen into range_indicator' do
          expect(types).to eq(%i[year range_indicator year])
        end
      end

      context 'when ambiguous_month_year: as_month' do
        let(:options){ {ambiguous_month_year: :as_month} }
        
        it 'removes hyphen' do
          expect(types).to eq(%i[year month])
        end
      end
    end

    context 'with 2 December 2020, 2020/02/15' do
      let(:str){ '2 December 2020, 2020/02/15' }
      
      it 'tags' do
        expect(types).to eq(%i[month day year comma year month day])
      end
    end

    context 'with 2004-06/2006-08' do
      let(:str){ '2004-06/2006-08' }
      
      context 'when default options' do
        it 'tags' do
          expect(types).to eq(%i[year month range_indicator year month])
        end
      end
    end

    context 'with Mar 19' do
      let(:str){ 'Mar 19' }
      
      it 'tags as month year' do
        expect(types).to eq(%i[month year])
      end

      context 'when default options (coerce to 4-digit year) and current year 2022' do
        before{ allow(Date).to receive(:today).and_return Date.new(2022, 2, 3) }
        
        it 'converts year to 2019' do
          expect(result[1].literal).to eq(2019)
        end
      end

      context 'when two_digit_year_handling: literal' do
        let(:options){ {two_digit_year_handling: :literal} }
        
        it 'leaves year as 19' do
          expect(result[1].literal).to eq(19)
        end
      end
    end

    context 'with 10-02-06' do
      let(:str){ '10-02-06' }

      context 'with ambiguous_month_day_year: :month_day_year' do
        let(:options){ {ambiguous_month_day_year: :month_day_year} }

        it 'tags month day year', skip: 'not yet implemented' do
          expect(types).to eq(%i[month day year])
        end
      end

      context 'with ambiguous_month_day_year: :day_month_year' do
        let(:options){ {ambiguous_month_day_year: :day_month_year} }

        it 'tags day month year', skip: 'not yet implemented' do
          expect(types).to eq(%i[day month year])
        end
      end

      context 'with ambiguous_month_day_year: :year_month_day' do
        let(:options){ {ambiguous_month_day_year: :year_month_day} }

        it 'tags year month day', skip: 'not yet implemented' do
          expect(types).to eq(%i[year month day])
        end
      end

      context 'with ambiguous_month_day_year: :year_day_month' do
        let(:options){ {ambiguous_month_day_year: :year_day_month} }

        it 'tags year day month', skip: 'not yet implemented' do
          expect(types).to eq(%i[year day month])
        end
      end
    end
  end
end
