# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::DatePartTagger do
  subject { described_class.call(tokens) }

  let(:tokens) { prepped_for(string: string, target: described_class) }
  let(:result) { subject.value! }
  let(:types) { result.types }

  context "with ###" do
    let(:string) { "999" }

    it "tags year" do
      expect(types).to eq(%i[year])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ####" do
    let(:string) { "2020" }

    it "tags year" do
      expect(types).to eq(%i[year])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ####.#" do
    let(:string) { "2020.0" }

    it "tags year" do
      expect(types).to eq(%i[year])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with MONTH" do
    let(:string) { "March" }

    it "tags month" do
      expect(types).to eq(%i[month])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with [ca. ####s]", :ambiguous_decade_century_millennium do
    before do
      Emendate.config.options.pluralized_date_interpretation = :broad
    end

    let(:string) { "[ca. 2000s]" }

    it "segments as expected" do
      expect(types).to eq(%i[millennium])
      expect(result.lexeme).to eq(string)
      expect(result[0].sources.types).to include(:letter_s)
    end
  end

  context "with ####s ####s", :ambiguous_decade_century_millennium do
    let(:string) { "0000s 1000s" }

    it "tags decade and warns of ambiguity" do
      expect(types).to eq(%i[decade decade])
      expect(result.lexeme).to eq(string)
      w = ["Interpreting pluralized year as decade",
        "Interpreting pluralized year as decade"]
      expect(result.warnings).to eq(w)
    end

    context "when pluralized_date_interpretation: :broad" do
      before do
        Emendate.config.options.pluralized_date_interpretation = :broad
      end

      it "tags millennium and warns of ambiguity" do
        expect(types).to eq(%i[millennium millennium])
        expect(result.lexeme).to eq(string)
        w = ["Interpreting pluralized year as millennium",
          "Interpreting pluralized year as millennium"]
        expect(result.warnings).to eq(w)
      end
    end
  end

  context "with ####s", :ambiguous_decade_century do
    let(:string) { "1900s" }

    it "tags decade" do
      expect(types).to eq(%i[decade])
      expect(result[0].literal).to eq(1900)
      expect(result.lexeme).to eq(string)
    end

    context "when pluralized_date_interpretation: :broad" do
      before do
        Emendate.config.options.pluralized_date_interpretation = :broad
      end

      it "tags century" do
        expect(types).to eq(%i[century])
        expect(result[0].literal).to eq(1900)
        expect(result.lexeme).to eq(string)
      end
    end
  end

  context "with ####s", :unambiguous_decade do
    let(:string) { "1990s" }

    it "tags decade" do
      expect(types).to eq(%i[decade])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ##ORD century" do
    let(:string) { "19th century" }

    it "tags century" do
      expect(types).to eq(%i[century])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ##uu" do
    let(:string) { "19uu" }

    it "tags century" do
      expect(types).to eq(%i[century])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with MONTH ##, ####" do
    let(:string) { "February 15, 2020" }

    it "tags day (month and year are already done at this point)" do
      expect(types).to eq(%i[month day year])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ####, MON ##" do
    let(:string) { "2020, Feb 15" }

    it "tags as expected" do
      expect(types).to eq(%i[year month day])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with #### MONTH #-#### MON ##" do
    let(:string) { "2000 June 3-2001 Jan 20" }

    it "tags as expected" do
      expect(types).to eq(
        %i[year month day range_indicator year month day]
      )
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ## MON ####" do
    let(:string) { "15 Feb 2020" }

    it "tags as expected" do
      expect(types).to eq(%i[day month year])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ##/####" do
    let(:string) { "03/2020" }

    it "tags as expected" do
      expect(types).to eq(%i[month year])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ####/##", :unambiguous_range do
    let(:string) { "1997/98" }

    it "tags as expected" do
      expect(result.lexeme).to eq(string)
      expect(types).to eq(%i[year range_indicator year])
    end
  end

  context 'with "MON ##, ####"' do
    let(:string) { "Oct. 28, 1964" }

    it "tags as expected" do
      expect(types).to eq(%i[month day year])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ##-##-##", :ambiguous_day_month_year do
    let(:string) { "10-02-06" }

    context "with ambiguous_month_day_year: :month_day_year" do
      before do
        Emendate.config.options.ambiguous_month_day_year = :month_day_year
      end

      it "tags month day year" do
        expect(types).to eq(%i[month day year])
        expect(result.lexeme).to eq(string)
      end
    end

    context "with ambiguous_month_day_year: :day_month_year" do
      before do
        Emendate.config.options.ambiguous_month_day_year = :day_month_year
      end

      it "tags day month year" do
        expect(types).to eq(%i[day month year])
        expect(result.lexeme).to eq(string)
      end
    end

    context "with ambiguous_month_day_year: :year_month_day" do
      before do
        Emendate.config.options.ambiguous_month_day_year = :year_month_day
      end

      it "tags year month day" do
        expect(types).to eq(%i[year month day])
        expect(result.lexeme).to eq(string)
      end
    end

    context "with ambiguous_month_day_year: :year_day_month" do
      before do
        Emendate.config.options.ambiguous_month_day_year = :year_day_month
      end

      it "tags year day month" do
        expect(types).to eq(%i[year day month])
        expect(result.lexeme).to eq(string)
      end
    end
  end

  context "with SEASON ##", :short_year do
    before do
      Emendate.config.options.ambiguous_year_rollback_threshold = 24
      allow(Date).to receive(:today).and_return Date.new(2001, 2, 3)
    end

    after { Emendate.reset_config }

    let(:string) { "Spring 20" }

    it "tags as expected" do
      expect(types).to eq(%i[season year])
      expect(result[1].literal).to eq(2020)
      expect(result[1].lexeme).to eq("20")
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ##-##-####", :ambiguous_day_month do
    let(:string) { "02-03-2020" }

    it "tags month day year" do
      expect(types).to eq(%i[month day year])
    end

    context "when ambiguous_month_day: :as_day_month" do
      before do
        Emendate.config.options.ambiguous_month_day = :as_day_month
      end

      it "tags day month year" do
        expect(types).to eq(%i[day month year])
        expect(result.lexeme).to eq(string)
      end
    end
  end

  context "with ####-##", :ambiguous_month_year do
    let(:string) { "2003-04" }

    it "converts hyphen into range_indicator" do
      expect(types).to eq(%i[year range_indicator year])
    end

    context "when ambiguous_month_year: as_month" do
      before do
        Emendate.config.options.ambiguous_month_year = :as_month
      end

      it "removes hyphen" do
        expect(types).to eq(%i[year month])
        expect(result.lexeme).to eq(string)
        expect(result[1].literal).to eq(4)
      end
    end

    context "when ambiguous_month_year: as_year" do
      before do
        Emendate.config.options.ambiguous_month_year = :as_year
      end

      it "tags as expected" do
        expect(types).to eq(%i[year range_indicator year])
        expect(result.lexeme).to eq(string)
        expect(result[2].literal).to eq(2004)
      end
    end
  end

  context "with ca. ####-##", :unambiguous_year do
    let(:string) { "ca. 1955-60" }

    it "tags as expected" do
      expect(types).to eq(%i[year range_indicator year])
      expect(result.lexeme).to eq(string)
      expect(result[2].literal).to eq(1960)
    end
  end

  context "with ####-MON" do
    let(:string) { "1968-Mar" }

    it "formats as expected" do
      expect(result.lexeme).to eq(string)
      expect(types).to eq(%i[year month])
    end
  end

  context "with ##-####", :unambiguous_month_year do
    let(:string) { "12-2011" }

    it "returns as expected" do
      expect(result.lexeme).to eq(string)
      expect(types).to eq(%i[month year])
    end
  end

  context "with # MONTH ####, ####/##/##" do
    let(:string) { "2 December 2020, 2020/02/15" }

    it "tags" do
      expect(types).to eq(%i[day month year comma year month day])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ####-##/####-##", :unambiguous_month_year do
    # The fact that the dates are the start/end of a range makes them
    # unambiguous
    let(:string) { "2004-06/2006-08" }

    it "tags" do
      expect(types).to eq(%i[year month range_indicator year month])
      expect(result.lexeme).to eq(string)
      expect(result.map(&:literal).compact).to eq([2004, 6, 2006, 8])
    end
  end

  context "with mid ####s to ##/##/####" do
    let(:string) { "mid 1800s to 2/23/1921" }

    it "tags" do
      expect(types).to eq(%i[partial decade range_indicator month day year])
      expect(result.lexeme).to eq(string)
      expect(result.map(&:literal).compact).to eq([:mid, 1800, 2, 23, 1921])
    end
  end

  context "with MON ##", :short_year do
    let(:string) { "Mar 19" }

    it "tags as month year" do
      expect(types).to eq(%i[month year])
      expect(result.lexeme).to eq(string)
    end

    context "current year 2022" do
      before { allow(Date).to receive(:today).and_return Date.new(2022, 2, 3) }

      it "converts year to 2019" do
        expect(result[1].literal).to eq(2019)
        expect(result.lexeme).to eq(string)
      end
    end

    context "when two_digit_year_handling: literal" do
      before do
        Emendate.config.options.two_digit_year_handling = :literal
      end

      it "leaves year as 19" do
        expect(result[1].literal).to eq(19)
        expect(result.lexeme).to eq(string)
      end
    end
  end
end
