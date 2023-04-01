# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Emendate::FormatStandardizer do
  subject(:step){ described_class }

  describe '.call' do
    let(:tokens){ prepped_for(string: string, target: step) }
    let(:result) do
      step.call(tokens)
        .value!
        .types
    end

    context 'with 1984-?' do
      let(:string){ '1984-?' }

      it 'replaces question with rangedateopen_date_type' do
        expect(result).to eq(%i[number4 hyphen rangedateunknown_date_type])
      end
    end

    context 'with mid to late 1980s' do
      let(:string){ 'mid to late 1980s' }

      it 'adds after first partial' do
        expect(result).to eq(
          %i[partial number4 letter_s
             range_indicator
             partial number4 letter_s]
        )
      end
    end

    context 'with 1997/98' do
      let(:string){ '1997/98' }

      it 'replace slash with hyphen' do
        expect(result).to eq(%i[number4 hyphen number1or2])
      end
    end

    context 'with 2020, Feb.' do
      let(:string){ '2020, Feb.' }

      it 'reorders segments' do
        expect(result).to eq(%i[month number4])
      end
    end

    context 'with 1968-Mar' do
      let(:string){ '1968-Mar' }

      it 'reorders segments' do
        expect(result).to eq(%i[month number4])
      end
    end

    context 'with 2020, Feb 15' do
      let(:string){ '2020, Feb 15' }

      it 'reorders segments' do
        expect(result).to eq(%i[month number1or2 number4])
      end
    end

    context 'with 2020, summer' do
      let(:string){ '2020, summer' }

      it 'reorders segments' do
        expect(result).to eq(%i[season number4])
      end
    end

    context 'with c. 999-1-1' do
      let(:string){ 'c. 999-1-1' }

      it 'pads to 4-digit number' do
        expect(result).to eq(%i[number4 hyphen number1or2 hyphen number1or2])
      end
    end

    context 'with 18th or 19th century' do
      let(:string){ '18th or 19th century' }

      it 'adds century after 18th' do
        expect(result).to eq(
          %i[number1or2 century date_separator number1or2 century]
        )
      end
    end

    context 'with early to mid-19th century' do
      let(:string){ 'early to mid-19th century' }

      it 'adds 19th century after early' do
        expect(result).to eq(
          %i[partial number1or2 century range_indicator partial number1or2
             century]
        )
      end
    end

    context 'with Feb. 15, 999 - February 20, 2020' do
      let(:string){ 'Feb. 15, 999 - February 20, 2020' }

      it 'removes commas after dates' do
        expect(result).to eq(
          %i[month number1or2 number4 hyphen month number1or2 number4]
        )
      end
    end

    context 'with May - June 2000' do
      let(:string){ 'May - June 2000' }

      it 'adds year after first month' do
        expect(result).to eq(%i[month number4 hyphen month number4])
      end
    end

    context 'with June 1- July 4, 2000' do
      let(:string){ 'June 1- July 4, 2000' }

      it 'adds year after first month/day' do
        expect(result).to eq(
          %i[month number1or2 number4 hyphen month number1or2 number4]
        )
      end
    end

    context 'with June 3-15, 2000' do
      let(:string){ 'June 3-15, 2000' }

      it 'adds year after first month/day; adds month before day/year' do
        expect(result).to eq(
          %i[month number1or2 number4 hyphen month number1or2 number4]
        )
      end
    end

    context 'with 2000 May -June' do
      let(:string){ '2000 May -June' }

      it 'move first month to front; copy year to end' do
        expect(result).to eq(%i[month number4 hyphen month number4])
      end
    end

    context 'with 2000 June 3-2001 Jan 20' do
      let(:string){ '2000 June 3-2001 Jan 20' }

      it 'move year to end of segment' do
        expect(result).to eq(
          %i[month number1or2 number4 hyphen month number1or2 number4]
        )
      end
    end

    context 'with 15 Feb 2020' do
      let(:string){ '15 Feb 2020' }

      it 'move month to front of segment' do
        expect(result).to eq(%i[month number1or2 number4])
      end
    end

    context 'with 1985-04-12T23:20:30' do
      let(:string){ '1985-04-12T23:20:30' }

      it 'remove time segments' do
        expect(result).to eq(%i[number4 hyphen number1or2 hyphen number1or2])
      end
    end

    context 'with 1985-04-12T23:20:30Z' do
      let(:string){ '1985-04-12T23:20:30Z' }

      it 'remove time segments' do
        expect(result).to eq(%i[number4 hyphen number1or2 hyphen number1or2])
      end
    end

    context 'with 1997-1998 A.D.' do
      let(:string){ '1997-1998 A.D.' }

      it 'remove CE and equivalent era' do
        expect(result).to eq(%i[number4 hyphen number4])
      end
    end

    context 'with ../2021' do
      let(:string){ '../2021' }

      it 'replace double dot with open start date type' do
        expect(result).to eq(%i[rangedateopen_date_type hyphen number4])
      end
    end

    context 'with 1985/..' do
      let(:string){ '1985/..' }

      it 'replace double dot with open end date type' do
        expect(result).to eq(%i[number4 hyphen rangedateopen_date_type])
      end
    end

    context 'with 1985/' do
      let(:string){ '1985/' }

      it 'appends open end date type' do
        expect(result).to eq(%i[number4 range_indicator rangedateopen_date_type])
      end

      context 'with ending_slash: :unknown' do
        before(:context) do
          Emendate.config.options.ending_slash = :unknown
        end
        after(:context){ Emendate.reset_config }

        it 'appends unknown end date type' do
          expect(result).to eq(%i[number4 range_indicator rangedateunknown_date_type])
        end
      end
    end

    context 'with 1985-' do
      let(:string){ '1985-' }

      it 'appends open end date type' do
        expect(result).to eq(%i[number4 range_indicator rangedateopen_date_type])
      end
    end

    context 'with 165X' do
      let(:string){ '165X' }

      it 'replaces 165X with decade_as_year date type' do
        expect(result).to eq(%i[decade_date_type])
      end
    end
  end
end
