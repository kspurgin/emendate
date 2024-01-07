# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::DatePartTagger do
  subject(:step){ described_class }

  describe '.call' do
    let(:tokens){ prepped_for(string: string, target: step) }
    let(:result) do
      step.call(tokens)
          .value!
    end
    let(:types){ result.types }

    context 'with 999' do
      let(:string){ '999' }

      it 'tags year' do
        expect(types).to eq(%i[year])
      end
    end

    context 'with 2020' do
      let(:string){ '2020' }

      it 'tags year' do
        expect(types).to eq(%i[year])
      end
    end

    context 'with 2020.0' do
      let(:string){ '2020.0' }

      it 'tags year' do
        expect(types).to eq(%i[year])
      end
    end

    context 'with March' do
      let(:string){ 'March' }

      it 'tags month' do
        expect(types).to eq(%i[month])
      end
    end

    context 'with 0000s 1000s' do
      let(:string){ '0000s 1000s' }

      it 'tags decade and warns of ambiguity' do
        expect(types).to eq(%i[decade decade])
        w = ['Interpreting pluralized year as decade',
             'Interpreting pluralized year as decade']
        expect(w - result.warnings).to be_empty
      end

      context 'when pluralized_date_interpretation: :broad' do
        before do
          Emendate::Options.new({ pluralized_date_interpretation: :broad })
        end

        after{ Emendate.reset_config }

        it 'tags millennium and warns of ambiguity' do
          expect(types).to eq(%i[millennium millennium])
          w = ['Interpreting pluralized year as millennium',
               'Interpreting pluralized year as millennium']
          expect(w - result.warnings).to be_empty
        end
      end
    end

    context 'with 1900s' do
      let(:string){ '1900s' }

      it 'tags decade' do
        expect(types).to eq(%i[decade])
        expect(result[0].literal).to eq(1900)
      end

      context 'when pluralized_date_interpretation: :broad' do
        before do
          Emendate::Options.new({ pluralized_date_interpretation: :broad })
        end

        after{ Emendate.reset_config }

        it 'tags century' do
          expect(types).to eq(%i[century])
          expect(result[0].literal).to eq(1900)
        end
      end
    end

    context 'with 1990s' do
      let(:string){ '1990s' }

      it 'tags decade' do
        expect(types).to eq(%i[decade])
      end
    end

    context 'with 19th century' do
      let(:string){ '19th century' }

      it 'tags century' do
        expect(types).to eq(%i[century])
      end
    end

    context 'with 19uu' do
      let(:string){ '19uu' }

      it 'tags century' do
        expect(types).to eq(%i[century])
      end
    end

    context 'with February 15, 2020' do
      let(:string){ 'February 15, 2020' }

      it 'tags day (month and year are already done at this point)' do
        expect(types).to eq(%i[month day year])
      end
    end

    context 'with 03/2020' do
      let(:string){ '03/2020' }

      it 'tags as expected' do
        expect(types).to eq(%i[month year])
      end
    end

    context 'with February 30, 2020' do
      let(:string){ 'February 30, 2020' }

      it 'returns error' do
        res = step.call(tokens)
        expect(res).to be_a(Dry::Monads::Failure)
        expect(res.failure).to be_a(Emendate::UntaggableDatePartError)
      end
    end

    context 'with "Oct. 28, 1964"' do
      let(:string){ 'Oct. 28, 1964' }

      it 'tags as expected' do
        expect(types).to eq(%i[month day year])
      end
    end

    context 'with 2-10-20 and current year is 2020' do
      before do
        Emendate::Options.new({ ambiguous_year_rollback_threshold: 20 })
        allow(Date).to receive(:today).and_return Date.new(2020, 2, 3)
      end

      after{ Emendate.reset_config }

      let(:string){ '2-10-20' }

      it 'tags month (2), day (10), and short year (1920)' do
        expect(types).to eq(%i[yearmonthday_date_type])
        expect(result.first.year).to eq(1920)
        expect(result.first.month).to eq(2)
        expect(result.first.day).to eq(10)
      end
    end

    context 'with Spring 20, threshold 24, and current century 2000s' do
      before do
        Emendate.config.options.ambiguous_year_rollback_threshold = 24
        allow(Date).to receive(:today).and_return Date.new(2001, 2, 3)
      end

      after{ Emendate.reset_config }

      let(:string){ 'Spring 20' }

      it 'tags as expected' do
        expect(types).to eq(%i[season year])
        expect(result[1].literal).to eq(2020)
        expect(result[1].lexeme).to eq('20')
      end
    end

    context 'with 02-03-2020' do
      let(:string){ '02-03-2020' }

      it 'tags month day year' do
        expect(types).to eq(%i[month day year])
      end

      context 'when ambiguous_month_day: :as_day_month' do
        before do
          Emendate::Options.new({ ambiguous_month_day: :as_day_month })
        end

        after{ Emendate.reset_config }

        it 'tags day month year' do
          expect(types).to eq(%i[day month year])
        end
      end
    end

    context 'with 2003-04' do
      let(:string){ '2003-04' }

      it 'converts hyphen into range_indicator' do
        expect(types).to eq(%i[year range_indicator year])
      end

      context 'when ambiguous_month_year: as_month' do
        before do
          Emendate::Options.new({ ambiguous_month_year: :as_month })
        end

        after{ Emendate.reset_config }

        it 'removes hyphen' do
          expect(types).to eq(%i[year month])
        end
      end
    end

    context 'with 2 December 2020, 2020/02/15' do
      let(:string){ '2 December 2020, 2020/02/15' }

      it 'tags' do
        expect(types).to eq(%i[month day year comma year month day])
      end
    end

    context 'with 2004-06/2006-08' do
      let(:string){ '2004-06/2006-08' }

      context 'when default options' do
        it 'tags' do
          expect(types).to eq(%i[year month range_indicator year month])
        end
      end
    end

    context 'with Mar 19' do
      let(:string){ 'Mar 19' }

      it 'tags as month year' do
        expect(types).to eq(%i[month year])
      end

      context 'current year 2022' do
        before{ allow(Date).to receive(:today).and_return Date.new(2022, 2, 3) }

        it 'converts year to 2019' do
          expect(result[1].literal).to eq(2019)
        end
      end

      context 'when two_digit_year_handling: literal' do
        before do
          Emendate::Options.new({ two_digit_year_handling: :literal })
        end

        after{ Emendate.reset_config }

        it 'leaves year as 19' do
          expect(result[1].literal).to eq(19)
        end
      end
    end

    context 'with 10-02-06' do
      let(:string){ '10-02-06' }

      context 'with ambiguous_month_day_year: :month_day_year' do
        let(:options){ { ambiguous_month_day_year: :month_day_year } }

        it 'tags month day year', skip: 'not yet implemented' do
          expect(types).to eq(%i[month day year])
        end
      end

      context 'with ambiguous_month_day_year: :day_month_year' do
        let(:options){ { ambiguous_month_day_year: :day_month_year } }

        it 'tags day month year', skip: 'not yet implemented' do
          expect(types).to eq(%i[day month year])
        end
      end

      context 'with ambiguous_month_day_year: :year_month_day' do
        let(:options){ { ambiguous_month_day_year: :year_month_day } }

        it 'tags year month day', skip: 'not yet implemented' do
          expect(types).to eq(%i[year month day])
        end
      end

      context 'with ambiguous_month_day_year: :year_day_month' do
        let(:options){ { ambiguous_month_day_year: :year_day_month } }

        it 'tags year day month', skip: 'not yet implemented' do
          expect(types).to eq(%i[year day month])
        end
      end
    end
  end
end
