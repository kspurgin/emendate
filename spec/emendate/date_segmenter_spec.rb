# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::DateSegmenter do
  subject { described_class.call(tokens) }

  let(:tokens) { prepped_for(string: string, target: described_class) }
  let(:result) { subject.value! }
  let(:types) { result.types }
  let(:warnings) { result.warnings }

  context "with #### and #### or ####-####" do
    let(:string) { "1932 and 1942 or 1948-1949" }

    it "fails" do
      expect(subject.failure[0].message).to eq("Multiple date separator types")
    end
  end

  context "with early MONTH ##, ####" do
    let(:string) { "early April 13, 1987" }

    it "fails" do
      expect(subject.failure[0].message).to eq(
        "Cannot prepend :partial segment to "\
          "Emendate::DateTypes::YearMonthDay sources"
      )
    end
  end

  context "with ####, MON ##" do
    let(:string) { "2020, Feb 15" }

    it "segments as expected" do
      expect(types).to eq(%i[yearmonthday_date_type])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with c.##" do
    let(:string) { "c.55" }

    it "segments as expected" do
      expect(types).to eq(%i[year_date_type])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ####, ####" do
    let(:string) { "1997, 2000" }

    it "segments as expected" do
      expect(types).to eq(%i[year_date_type date_separator year_date_type])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ####｜#### MON" do
    let(:string) { "1979｜1980 Jan" }

    it "segments as expected" do
      expect(types).to eq(%i[year_date_type date_separator yearmonth_date_type])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ####/##", :unambiguous_year_year do
    let(:string) { "1997/98" }

    it "segments as expected" do
      expect(types).to eq(%i[year_date_type range_indicator year_date_type])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ####, around MONTH ##" do
    let(:string) { "1987, around April 13" }

    it "segments as expected" do
      expect(types).to eq(%i[yearmonthday_date_type])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ####-MON" do
    let(:string) { "1968-Mar" }

    it "segments as expected" do
      expect(types).to eq(%i[yearmonth_date_type])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ##-####", :unambiguous_month_year do
    let(:string) { "12-2011" }

    it "segments as expected" do
      expect(types).to eq(%i[yearmonth_date_type])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with #### MONTH -MONTH" do
    let(:string) { "2000 May -June" }

    it "segments as expected" do
      expect(types).to eq(%i[yearmonth_date_type range_indicator
        yearmonth_date_type])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ####-#### or ####-####" do
    let(:string) { "1932-1942 or 1948-1949" }

    it "segments as expected" do
      expect(types).to eq(
        %i[year_date_type range_indicator year_date_type
          date_separator
          year_date_type range_indicator year_date_type]
      )
      expect(result.set_type).to eq(:alternate)
      expect(warnings.length).to eq(0)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with circa ######", :six_digit, :ambiguous_longyear do
    let(:string) { "circa 202127" }

    context "when max_month_number_handling: :months" do
      before { Emendate.config.options.max_month_number_handling = :months }

      it "segments as expected" do
        expect(types).to eq(%i[year_date_type])
        expect(warnings.length).to eq(1)
        expect(result[0].literal).to eq(202127)
        expect(result.lexeme).to eq(string)
      end
    end

    context "when max_month_number_handling: :edtf_level_2", skip:
    "not yet implemented" do
      before do
        Emendate.config.options.max_month_number_handling = :edtf_level_2
      end

      it "segments as expected" do
        expect(types).to eq(%i[yearseason_date_type])
        expect(warnings.length).to eq(1)
        expect(result[0].literal).to eq(202127)
        expect(result.lexeme).to eq(string)
      end
    end
  end

  context "with circa ######", :ambiguous_longyear, :six_digit do
    let(:string) { "circa 202002" }

    it "segments as expected" do
      expect(types).to eq(%i[yearmonth_date_type])
      expect(result[0].earliest.year).to eq(2020)
      expect(result[0].earliest.month).to eq(2)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ca. ####-##", :ambiguous_month_year do
    before { Emendate.config.options.ambiguous_month_year = :as_month }

    let(:string) { "ca. 2002-10" }

    it "segments as expected" do
      expect(types).to eq(%i[yearmonth_date_type])
      expect(result[0].earliest.year).to eq(2002)
      expect(result[0].earliest.month).to eq(10)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ####, SEASON" do
    let(:string) { "2002, summer" }

    it "segments as expected" do
      expect(types).to eq(%i[yearseason_date_type])
      expect(result[0].earliest.year).to eq(2002)
      expect(result[0].earliest.month).to eq(7)
      expect(result[0].literal).to eq(200222)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with SEASON ####-####" do
    let(:string) { "autumn 2019-2020" }

    it "segments as expected" do
      expect(types).to eq(%i[yearseason_date_type range_indicator
        year_date_type])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with SEASON ####-####", :one_winter do
    let(:string) { "Winter 2019-2020" }

    it "segments as expected" do
      expect(types).to eq(%i[yearseason_date_type])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with SEASON ####-####", :non_consecutive_years do
    let(:string) { "Winter 2019-2023" }

    it "segments as expected" do
      expect(types).to eq(%i[yearseason_date_type range_indicator
        year_date_type])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ########", :eight_digit, :valid_ymd do
    let(:string) { "20200229" }

    it "segments as expected" do
      expect(types).to eq(%i[yearmonthday_date_type])
      expect(result[0].earliest.year).to eq(2020)
      expect(result[0].earliest.month).to eq(2)
      expect(result[0].earliest.day).to eq(29)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ########", :eight_digit, :invalid_ymd do
    let(:string) { "10000007" }

    it "segments as expected" do
      expect(types).to eq(%i[year_date_type])
      expect(result.warnings).to include("10000007 treated as a long year")
      expect(result[0].literal).to eq(10000007)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ########-########", :eight_digit, :valid_ymd do
    let(:string) { "20200229-20200304" }

    it "segments as expected" do
      e = %i[yearmonthday_date_type range_indicator yearmonthday_date_type]
      expect(types).to eq(e)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with after ####" do
    let(:string) { "after 1815" }

    it "segments as expected" do
      expect(types).to eq(%i[year_date_type])
      expect(result[0].range_switch).to eq(:after)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with early ##ORD c." do
    let(:string) { "early 19th c." }

    it "segments as expected" do
      expect(types).to eq(%i[century_date_type])
      expect(result[0].partial_indicator).to eq(:early)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with mid-##ORD century" do
    let(:string) { "mid-19th century" }

    it "segments as expected" do
      expect(types).to eq(%i[century_date_type])
      expect(result[0].partial_indicator).to eq(:mid)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with before early ##ORD c." do
    let(:string) { "before early 19th c." }

    it "segments as expected" do
      expect(types).to eq(%i[century_date_type])
      expect(result[0].partial_indicator).to eq(:early)
      expect(result[0].range_switch).to eq(:before)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ####s early" do
    let(:string) { "1950s early" }

    it "segments as expected" do
      expect(types).to eq(%i[decade_date_type])
      expect(result[0].partial_indicator).to eq(:early)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ##ORD or ##ORD century" do
    let(:string) { "17th or 18th century" }

    it "segments as expected" do
      e = %i[century_date_type date_separator century_date_type]
      expect(types).to eq(e)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with late ##ORD to early ##ORD century" do
    let(:string) { "late 19th to early 20th century" }

    it "segments as expected" do
      expect(types).to eq(%i[century_date_type range_indicator
        century_date_type])
      expect(result[0].partial_indicator).to eq(:late)
      expect(result[2].partial_indicator).to eq(:early)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with #-##-##" do
    let(:string) { "2-15-20" }

    it "returns yearmonthday_date_type" do
      expect(types).to eq(%i[yearmonthday_date_type])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ####-present" do
    let(:string) { "1974-present" }

    it "segments as expected" do
      expect(types).to eq(
        %i[year_date_type range_indicator yearmonthday_date_type]
      )
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ### ERA_BCE" do
    let(:string) { "231 BCE" }

    it "segments as expected" do
      expect(types).to eq(%i[year_date_type])
      expect(result[0].era).to eq(:bce)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ### ERA_BCE to ### ERA_BCE" do
    let(:string) { "251 BCE to 231 BCE" }

    it "segments as expected" do
      expect(types).to eq(%i[year_date_type range_indicator year_date_type])
      expect(result[0].era).to eq(:bce)
      expect(result[2].era).to eq(:bce)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with [ca. ####s]", :ambiguous_decade_century_millennium do
    before do
      Emendate.config.options.pluralized_date_interpretation = :broad
    end

    let(:string) { "[ca. 2000s]" }

    it "segments as expected" do
      expect(types).to eq(%i[millennium_date_type])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with SEASON ##", :short_year do
    before do
      Emendate.config.options.two_digit_year_handling = :coerce
      Emendate.config.options.ambiguous_year_rollback_threshold = 50
    end

    let(:string) { "Spring 20" }

    it "segments as expected" do
      expect(types).to eq(%i[yearseason_date_type])
      expect(result.lexeme).to eq(string)
    end
  end

  # context 'with 2 December 2020, 2020/02/15' do
  #   it 'returns yearmonthday_date_type comma yearmonthday_datetype' do
  #     s = segment('2 December 2020, 2020/02/15')
  #     e = %i[yearmonthday_date_type comma yearmonthday_date_type]
  #     expect(s.types).to eq(e)
  #   end
  # end

  # context 'with Mar 20' do
  #   it 'returns yearmonth_date_type' do
  #     s = segment('Mar 20')
  #     e = %i[yearmonth_date_type]
  #     expect(s.types).to eq(e)
  #   end
  # end

  # context 'with 1990s 199X' do
  #   before(:all){ @s = segment('1990s 199X') }

  #   it 'returns decade_date_types' do
  #     e = %i[decade_date_type decade_date_type]
  #     expect(@s.types).to eq(e)
  #   end

  #   it 'returns decade_types: plural, uncertainty_digits' do
  #     e = 'plural uncertainty_digits'
  #     expect(@s.map(&:decade_type).join(' ')).to eq(e)
  #   end
  # end

  # context 'with 1900s (as century), 19th century, 19uu' do
  #   before(:all) do
  # rubocop:todo Layout/LineLength
  #     @s = segment('1900s 19th century 19uu', pluralized_date_interpretation: :broad)
  # rubocop:enable Layout/LineLength
  #   end

  #   it 'returns century_date_types' do
  #     e = %i[century_date_type century_date_type century_date_type]
  #     expect(@s.types).to eq(e)
  #   end

  #   it 'returns century_types: plural, name, uncertainty_digits' do
  #     e = 'plural name uncertainty_digits'
  #     expect(@s.map(&:century_type).join(' ')).to eq(e)
  #   end

  #   it 'returns century literals: 19 19 19' do
  #     expect(@s.map(&:literal).join(' ')).to eq('19 19 19')
  #   end
  # end

  # context 'with 1972 - 1999' do
  #   before(:all){ @s = segment('1972 - 1999') }

  #   it 'returns: year_date_type range_indicator year_date_type' do
  # rubocop:todo Layout/LineLength
  #     expect(@s.type_string).to eq('year_date_type range_indicator year_date_type')
  # rubocop:enable Layout/LineLength
  #   end
  # end
end
