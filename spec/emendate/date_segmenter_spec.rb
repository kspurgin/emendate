# frozen_string_literal: true

require "spec_helper"

RSpec.describe Emendate::DateSegmenter do
  subject { described_class.call(tokens) }

  let(:tokens) { prepped_for(string: string, target: described_class) }
  let(:result) { subject.value! }
  let(:types) { result.types }
  let(:warnings) { result.warnings }

  context "with 1932 and 1942 or 1948-1949" do
    let(:string) { "1932 and 1942 or 1948-1949" }

    it "fails" do
      expect(subject.failure).to eq(:multiple_date_separator_types)
    end
  end

  context "with 2020, Feb 15" do
    let(:string) { "2020, Feb 15" }

    it "segments as expected" do
      expect(types).to eq(%i[yearmonthday_date_type])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with 1987, around April 13" do
    let(:string) { "1987, around April 13" }

    it "segments as expected" do
      expect(types).to eq(%i[yearmonthday_date_type])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with 1968-Mar" do
    let(:string) { "1968-Mar" }

    it "segments as expected" do
      expect(types).to eq(%i[yearmonth_date_type])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with 12-2011" do
    let(:string) { "12-2011" }

    it "segments as expected" do
      expect(types).to eq(%i[yearmonth_date_type])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with 2000 May -June" do
    let(:string) { "2000 May -June" }

    it "segments as expected" do
      expect(types).to eq(%i[yearmonth_date_type range_indicator
        yearmonth_date_type])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with 1932-1942 or 1948-1949" do
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

  context "with circa 202127" do
    let(:string) { "circa 202127" }

    it "segments as expected" do
      expect(types).to eq(%i[year_date_type])
      expect(warnings.length).to eq(1)
      expect(result[0].literal).to eq(202127)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with circa 202002" do
    let(:string) { "circa 202002" }

    it "segments as expected" do
      expect(types).to eq(%i[yearmonth_date_type])
      expect(result[0].earliest.year).to eq(2020)
      expect(result[0].earliest.month).to eq(2)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with ca. 2002-10" do
    before { Emendate.config.options.ambiguous_month_year = :as_month }

    let(:string) { "ca. 2002-10" }

    it "segments as expected" do
      expect(types).to eq(%i[yearmonth_date_type])
      expect(result[0].earliest.year).to eq(2002)
      expect(result[0].earliest.month).to eq(10)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with 2002, summer" do
    let(:string) { "2002, summer" }

    it "segments as expected" do
      expect(types).to eq(%i[yearseason_date_type])
      expect(result[0].earliest.year).to eq(2002)
      expect(result[0].earliest.month).to eq(7)
      expect(result[0].literal).to eq(200222)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with autumn 2019-2020" do
    let(:string) { "autumn 2019-2020" }

    it "segments as expected" do
      expect(types).to eq(%i[yearseason_date_type range_indicator
        year_date_type])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with Winter 2019-2020" do
    let(:string) { "Winter 2019-2020" }

    it "segments as expected" do
      expect(types).to eq(%i[yearseason_date_type])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with Winter 2019-2023" do
    let(:string) { "Winter 2019-2023" }

    it "segments as expected" do
      expect(types).to eq(%i[yearseason_date_type range_indicator
        year_date_type])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with 20200229" do
    let(:string) { "20200229" }

    it "segments as expected" do
      expect(types).to eq(%i[yearmonthday_date_type])
      expect(result[0].earliest.year).to eq(2020)
      expect(result[0].earliest.month).to eq(2)
      expect(result[0].earliest.day).to eq(29)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with 10000007" do
    let(:string) { "10000007" }

    it "segments as expected" do
      expect(types).to eq(%i[year_date_type])
      expect(result.warnings).to include("10000007 treated as a long year")
      expect(result[0].literal).to eq(10000007)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with 20200229-20200304" do
    let(:string) { "20200229-20200304" }

    it "segments as expected" do
      e = %i[yearmonthday_date_type range_indicator yearmonthday_date_type]
      expect(types).to eq(e)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with after 1815" do
    let(:string) { "after 1815" }

    it "segments as expected" do
      expect(types).to eq(%i[year_date_type])
      expect(result[0].range_switch).to eq(:after)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with early 19th c." do
    let(:string) { "early 19th c." }

    it "segments as expected" do
      expect(types).to eq(%i[century_date_type])
      expect(result[0].partial_indicator).to eq(:early)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with mid-19th century" do
    let(:string) { "mid-19th century" }

    it "segments as expected" do
      expect(types).to eq(%i[century_date_type])
      expect(result[0].partial_indicator).to eq(:mid)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with before early 19th c." do
    let(:string) { "before early 19th c." }

    it "segments as expected" do
      expect(types).to eq(%i[century_date_type])
      expect(result[0].partial_indicator).to eq(:early)
      expect(result[0].range_switch).to eq(:before)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with 1950s early" do
    let(:string) { "1950s early" }

    it "segments as expected" do
      expect(types).to eq(%i[decade_date_type])
      expect(result[0].partial_indicator).to eq(:early)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with 17th or 18th century" do
    let(:string) { "17th or 18th century" }

    it "segments as expected" do
      e = %i[century_date_type date_separator century_date_type]
      expect(types).to eq(e)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with late 19th to early 20th century" do
    let(:string) { "late 19th to early 20th century" }

    it "segments as expected" do
      expect(types).to eq(%i[century_date_type range_indicator
        century_date_type])
      expect(result[0].partial_indicator).to eq(:late)
      expect(result[2].partial_indicator).to eq(:early)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with 2-15-20" do
    let(:string) { "2-15-20" }

    it "returns yearmonthday_date_type" do
      expect(types).to eq(%i[yearmonthday_date_type])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with 1974-present" do
    let(:string) { "1974-present" }

    it "segments as expected" do
      expect(types).to eq(
        %i[year_date_type range_indicator yearmonthday_date_type]
      )
      expect(result.lexeme).to eq(string)
    end
  end

  context "with 231 BCE" do
    let(:string) { "231 BCE" }

    it "segments as expected" do
      expect(types).to eq(%i[year_date_type])
      expect(result[0].era).to eq(:bce)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with 251 BCE to 231 BCE" do
    let(:string) { "251 BCE to 231 BCE" }

    it "segments as expected" do
      expect(types).to eq(%i[year_date_type range_indicator year_date_type])
      expect(result[0].era).to eq(:bce)
      expect(result[2].era).to eq(:bce)
      expect(result.lexeme).to eq(string)
    end
  end

  context "with [ca. 2000s] treated as millennium" do
    before do
      Emendate.config.options.pluralized_date_interpretation = :broad
    end

    let(:string) { "[ca. 2000s]" }

    it "segments as expected" do
      expect(types).to eq(%i[millennium_date_type])
      expect(result.lexeme).to eq(string)
    end
  end

  context "with Spring 20" do
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
