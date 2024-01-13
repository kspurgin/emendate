# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::FormatStandardizer do
  subject { described_class.call(tokens).value! }

  describe ".call" do
    let(:tokens) { prepped_for(string: string, target: described_class) }
    let(:result) { subject.types }

    context "with 1984-?" do
      let(:string) { "1984-?" }

      it "replaces question with rangedateopen_date_type" do
        expect(result).to eq(%i[number4 hyphen rangedateendunknown_date_type])
        expect(subject.lexeme).to eq(string)
      end
    end

    context "with mid to late 1980s" do
      let(:string) { "mid to late 1980s" }

      it "adds after first partial" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(
          %i[partial number4 letter_s
            range_indicator
            partial number4 letter_s]
        )
      end
    end

    context "with 1997/98" do
      let(:string) { "1997/98" }

      it "replace slash with hyphen" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[number4 hyphen number1or2])
      end
    end

    context "with 2020, Feb." do
      let(:string) { "2020, Feb." }

      it "reorders segments" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[yearmonth_date_type])
      end
    end

    context "with 1968-Mar" do
      let(:string) { "1968-Mar" }

      it "reorders segments" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[yearmonth_date_type])
      end
    end

    context "with 2020, Feb 15" do
      let(:string) { "2020, Feb 15" }

      it "creates date type" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[yearmonthday_date_type])
      end
    end

    context "with 2020, summer" do
      let(:string) { "2020, summer" }

      it "reorders segments" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[yearseason_date_type])
      end
    end

    context "with 12-2011" do
      let(:string) { "12-2011" }

      it "returns as expected" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[yearmonth_date_type])
      end
    end

    context "with c. 999-1-1" do
      let(:string) { "c. 999-1-1" }

      it "pads to 4-digit number" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[number4 hyphen number1or2 hyphen number1or2])
      end
    end

    context "with 18th or 19th century" do
      let(:string) { "18th or 19th century" }

      it "adds century after 18th" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(
          %i[number1or2 century date_separator number1or2 century]
        )
      end
    end

    context "with early to mid-19th century" do
      let(:string) { "early to mid-19th century" }

      it "adds 19th century after early" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(
          %i[partial number1or2 century range_indicator partial number1or2
            century]
        )
      end
    end

    context "with Feb. 15, 999 - February 20, 2020" do
      let(:string) { "Feb. 15, 999 - February 20, 2020" }

      it "removes commas after dates" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(
          %i[month number1or2 number4 hyphen month number1or2 number4]
        )
      end
    end

    context "with May - June 2000" do
      let(:string) { "May - June 2000" }

      it "adds year after first month" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[month number4 hyphen month number4])
      end
    end

    context "with June 1- July 4, 2000" do
      let(:string) { "June 1- July 4, 2000" }

      it "adds year after first month/day" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(
          %i[month number1or2 number4 hyphen month number1or2 number4]
        )
      end
    end

    context "with June 3-15, 2000" do
      let(:string) { "June 3-15, 2000" }

      it "adds year after first month/day; adds month before day/year" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(
          %i[month number1or2 number4 hyphen month number1or2 number4]
        )
      end
    end

    context "with 2000 May -June" do
      let(:string) { "2000 May -June" }

      it "move first month to front; copy year to end" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[yearmonth_date_type hyphen month number4])
      end
    end

    context "with 2000 June 3-2001 Jan 20" do
      let(:string) { "2000 June 3-2001 Jan 20" }

      it "move year to end of segment" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(
          %i[yearmonthday_date_type hyphen yearmonthday_date_type]
        )
      end
    end

    context "with 15 Feb 2020" do
      let(:string) { "15 Feb 2020" }

      it "move month to front of segment" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[yearmonthday_date_type])
      end
    end

    context "with 1985-04-12T23:20:30" do
      let(:string) { "1985-04-12T23:20:30" }

      it "remove time segments" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[number4 hyphen number1or2 hyphen number1or2])
      end
    end

    context "with 1985-04-12T23:20:30Z" do
      let(:string) { "1985-04-12T23:20:30Z" }

      it "remove time segments" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[number4 hyphen number1or2 hyphen number1or2])
      end
    end

    context "with 1997-1998 A.D." do
      let(:string) { "1997-1998 A.D." }

      it "remove CE and equivalent era" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[number4 hyphen number4])
      end
    end

    context "with 300 BCE" do
      let(:string) { "300 BCE" }

      it "passes through" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[number4 era_bce])
      end
    end

    context "with 350-300 BCE" do
      let(:string) { "350-300 BCE" }

      it "passes through" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[number4 era_bce hyphen number4 era_bce])
      end
    end

    context "with ../2021", :rangedateunknownoropen do
      let(:string) { "../2021" }

      it "replace double dot with open start date type" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[rangedatestartopen_date_type hyphen number4])
      end
    end

    context "with 1985/..", :rangedateunknownoropen do
      let(:string) { "1985/.." }

      it "replace double dot with open end date type" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[number4 hyphen rangedateendopen_date_type])
      end
    end

    context "with 1985/", :rangedateunknownoropen do
      let(:string) { "1985/" }

      it "appends open end date type" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[number4 range_indicator
          rangedateendopen_date_type])
      end

      context "with ending_slash: :unknown" do
        before(:context) do
          Emendate.config.options.ending_slash = :unknown
        end

        it "appends unknown end date type" do
          expect(subject.lexeme).to eq(string)
          expect(result).to eq(%i[number4 range_indicator
            rangedateendunknown_date_type])
        end
      end
    end

    context "with 1985-", :rangedateunknownoropen do
      let(:string) { "1985-" }

      it "appends open end date type" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[number4 range_indicator
          rangedateendopen_date_type])
      end
    end

    context "with 165X" do
      let(:string) { "165X" }

      it "replaces 165X with decade_as_year date type" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[decade_date_type])
      end
    end

    context "with early 19th c." do
      let(:string) { "early 19th c." }

      it "segments as expected" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[partial number1or2 century])
      end
    end

    context "with 18th or 19th c." do
      let(:string) { "18th or 19th c." }

      it "segments as expected" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[number1or2 century
          date_separator
          number1or2 century])
      end
    end

    context "with 2 December 2020, 2020/02/15" do
      let(:string) { "2 December 2020, 2020/02/15" }

      it "segments as expected" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[yearmonthday_date_type comma number4 hyphen
          number1or2 hyphen number1or2])
      end
    end

    context "with November '73" do
      let(:string) { "November '73" }

      it "segments as expected" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[month year])
        expect(subject[1].literal).to eq(1973)
      end
    end

    context "with invalid YMD values" do
      let(:string) { "1844 Jun 31" }

      it "segments as expected" do
        expect(subject.lexeme).to eq(string)
        expect(result).to eq(%i[invalid_date_type])
      end
    end
  end
end
