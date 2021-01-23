# frozen_string_literal: true

module Helpers
  extend self

  EXAMPLES = {
    'unknown' => [{ start: nil, end: nil, tags: %i[indicates_no_date] }],
    'undated' => [{ start: nil, end: nil, tags: %i[indicates_no_date] }],
    'n.d.' => [{ start: nil, end: nil, tags: %i[indicates_no_date] }],
    'nd' => [{ start: nil, end: nil, tags: %i[indicates_no_date] }],
    '02-03-2020' => [{ start: '2020-02-03', end: '2020-02-03', tags: %i[mdy ambiguous_year_month option] }],
    '02-15-2020' => [{ start: '2020-02-15', end: '2020-02-15', tags: %i[mdy] }],
    '2/15/2020' => [{ start: '2020-02-15', end: '2020-02-15', tags: %i[mdy] }],
    '02/15/2020' => [{ start: '2020-02-15', end: '2020-02-15', tags: %i[mdy] }],
    '2020-02-15' => [{ start: '2020-02-15', end: '2020-02-15', tags: %i[ymd] }],
    '2020/02/15' => [{ start: '2020-02-15', end: '2020-02-15', tags: %i[ymd] }],
    'Feb. 15, 2020' => [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }],
    'Feb 15, 2020' => [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }],
    'Feb 15 2020' => [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }],
    'Feb. 15 2020' => [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }],
    'February 15 2020' => [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }],
    'February 15, 2020' => [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }],  
    '15 February 2020' => [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }],
    '2020 February 15' => [{ start: '2020-02-15', end: '2020-02-15', tags: %i[ymd] }],
    '2020 Feb 15' => [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }],
    '20200215' => [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }],
    '15 Feb 2020' => [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }],
    '15 Feb. 2020' => [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }],
    '02-15-20' => [{ start: '2020-02-15', end: '2020-02-15', tags: %i[two_digit_year option] }],
    '1/2/2000 - 12/21/2001' => [{ start: '2000-01-02', end: '2001-12-21', tags: %i[inclusive_range] }],
    'VIII.XIV.MMXX' => [{ start: nil, end: nil, tags: %i[unparseable] }],
    'March 2020' => [{ start: '2020-03-01', end: '2020-03-31', tags: %i[month_year] }],
    '2020 Mar' => [{ start: '2020-03-01', end: '2020-03-31', tags: %i[month_year] }],
    '2020-03' => [{ start: '2020-03-01', end: '2020-03-31', tags: %i[month_year] }],
    '2020-3' => [{ start: '2020-03-01', end: '2020-03-31', tags: %i[month_year] }],
    '2002' => [{ start: '2002-01-01', end: '2002-12-31', tags: %i[] }],
    '2002 C.E.' => [{ start: '2002-01-01', end: '2002-12-31', tags: %i[] }],    
    '2002 B.C.E.' => [{ start: '-2002-01-01', end: '-2002-12-31', tags: %i[bce] }],
    '2002?' => [{ start: '2002-01-01', end: '2002-12-31', tags: %i[questionable] }],
    '2002 (?)' => [{ start: '2002-01-01', end: '2002-12-31', tags: %i[questionable] }],
    '[2002?]' => [{ start: '2002-01-01', end: '2002-12-31', tags: %i[inferred questionable] }],
    '1997-1998' => [{ start: '1997-01-01', end: '1998-12-31', tags: %i[inclusive_range] }],
    '[1997]-[1998]' => [{ start: '1997-01-01', end: '1998-12-31', tags: %i[inclusive_range inferred] }],
    '1997-1998 A.D.' => [{ start: '1997-01-01', end: '1998-12-31', tags: %i[inclusive_range] }],
    '[1997-1998]' => [{ start: '1997-01-01', end: '1998-12-31', tags: %i[inclusive_range inferred] }],    
    '1997/98' => [{ start: '1997-01-01', end: '1998-12-31', tags: %i[inclusive_range option] }],
    '1997-98' => [{ start: '1997-01-01', end: '1998-12-31', tags: %i[inclusive_range option] }],
    '1935, 1946-1947' => [
      { start: '1935-01-01', end: '1935-12-31', tags: %i[multi_date] },
      { start: '1946-01-01', end: '1947-12-31', tags: %i[inclusive_range multi_date] }],
    '1997 or 1999' => [
      { start: '1997-01-01', end: '1997-12-31', tags: %i[alternate_dates] },
      { start: '1999-01-01', end: '1999-12-31', tags: %i[alternate_dates] }],
    '[1997 or 1999]' => [
      { start: '1997-01-01', end: '1997-12-31', tags: %i[alternate_dates inferred] },
      { start: '1999-01-01', end: '1999-12-31', tags: %i[alternate_dates inferred] }],
    '1997 & 1999' => [
      { start: '1997-01-01', end: '1997-12-31', tags: %i[alternate_dates] },
      { start: '1999-01-01', end: '1999-12-31', tags: %i[alternate_dates] }],
    'before 1750' => [{ start: nil, end: '1750-01-01', tags: %i[before] }],    
    'after 1815' => [{ start: '1815-12-31', end: DateTime.now.to_date.iso8601, tags: %i[after_before] }],
    'circa 2002' => [{ start: '2002-01-01', end: '2002-12-31', tags: %i[approximate] }],
    '[circa 2002?]' => [{ start: '2002-01-01', end: '2002-12-31', tags: %i[approximate inferred questionable] }],
    'c. 2002' => [{ start: '2002-01-01', end: '2002-12-31', tags: %i[approximate] }],
    'c 2002' => [{ start: '2002-01-01', end: '2002-12-31', tags: %i[approximate] }],
    'c2002' => [{ start: '2002-01-01', end: '2002-12-31', tags: %i[approximate] }],
    'c. 1997-1998' => [{ start: '1997-01-01', end: '1998-12-31', tags: %i[inclusive_range approximate] }],
    'ca. 2002' => [{ start: '2002-01-01', end: '2002-12-31', tags: %i[approximate] }],
    'ca 2002' => [{ start: '2002-01-01', end: '2002-12-31', tags: %i[approximate] }],
    'ca. 1997-1998' => [{ start: '1997-01-01', end: '1998-12-31', tags: %i[inclusive_range approximate] }],
    '[ca. 2002]' => [{ start: '2002-01-01', end: '2002-12-31', tags: %i[approximate inferred] }],
    '[ca. 2002-10]' => [{ start: '2002-01-01', end: '2010-12-31', tags: %i[approximate inferred option] }],
    'ca. 1980s & 1990s' => [
      { start: '1980-01-01', end: '1989-12-31', tags: %i[inclusive_range approximate alternate_dates decades] },
      { start: '1990-01-01', end: '1999-12-31', tags: %i[inclusive_range approximate alternate_dates decades] }],
    '2000-01-01, 2001-01-01, 2002-02-02, 2003-03-03' => [
      { start: '2000-01-01', end: '2000-01-01', tags: %i[multi_date] },
      { start: '2003-03-03', end: '2003-03-03', tags: %i[multi_date] }],
    '2000-01-01 or 2000-01-12' => [
      { start: '2000-01-01', end: '2000-01-01', tags: %i[alternate_dates] },
      { start: '2000-01-12', end: '2000-01-12', tags: %i[alternate_dates] }],
    # this example makes no sense without the option set to non-default on the first value,
    #  but we're representing default expectations here
    '2000-01, 2001-01, 2002-02, 2003-03' => [
      { start: '2000-01-01', end: '2001-12-31', tags: %i[multi_date month_year option] },
      { start: '2001-01-01', end: '2001-01-31', tags: %i[multi_date month_year] },
      { start: '2002-02-01', end: '2002-02-28', tags: %i[multi_date month_year] },
      { start: '2003-03-01', end: '2003-03-31', tags: %i[multi_date month_year] }],
    '1990s' => [{ start: '1990-01-01', end: '1999-12-31', tags: %i[inclusive_range approximate decades] }],
    '199X' => [{ start: '1990-01-01', end: '1999-12-31', tags: %i[inclusive_range approximate decades] }],
    '199u' => [{ start: '1990-01-01', end: '1999-12-31', tags: %i[inclusive_range approximate decades] }],
    '1980s or 1990s' => [
      { start: '1980-01-01', end: '1989-12-31', tags: %i[inclusive_range approximate alternate_dates decades] },
      { start: '1990-01-01', end: '1999-12-31', tags: %i[inclusive_range approximate alternate_dates decades] }],
    '1980s & 1990s' => [
      { start: '1980-01-01', end: '1989-12-31', tags: %i[inclusive_range approximate alternate_dates decades] },
      { start: '1990-01-01', end: '1999-12-31', tags: %i[inclusive_range approximate alternate_dates decades] }],
    'Early 1990s' => [{ start: '1990-01-01', end: '1995-12-31', tags: %i[inclusive_range approximate partial decades] }],
    'Mid 1990s' => [{ start: '1993-01-01', end: '1998-12-31', tags: %i[inclusive_range approximate partial decades] }],    
    'Late 1990s' => [{ start: '1995-01-01', end: '1999-12-31', tags: %i[inclusive_range approximate partial decades] }],
    'Early 1990' => [{ start: '1990-01-01', end: '1990-04-30', tags: %i[inclusive_range approximate partial] }],
    'Mid 1990' => [{ start: '1990-05-01', end: '1990-08-31', tags: %i[inclusive_range approximate partial] }],    
    'Late 1990' => [{ start: '1990-09-01', end: '1990-12-31', tags: %i[inclusive_range approximate partial] }],
    'Spring 2020' => [{ start: '2020-04-01', end: '2020-06-30', tags: %i[inclusive_range season] }],
    'Spring 20' => [{ start: '2020-04-01', end: '2020-06-30', tags: %i[inclusive_range season two_digit_year option] }],
    '2000 June 3-15' => [{ start: '2020-06-03', end: '2020-06-15', tags: %i[inclusive_range] }],
    'June 3-15, 2000' => [{ start: '2020-06-03', end: '2020-06-15', tags: %i[inclusive_range] }],    
    'June 3 -15, 2000' => [{ start: '2020-06-03', end: '2020-06-15', tags: %i[inclusive_range] }],
    '2000 June 3, 15' => [
      { start: '2000-06-03', end: '2000-06-03', tags: %i[multi_date] },
      { start: '2000-06-15', end: '2000-06-15', tags: %i[multi_date] }],
    '2000 June 1-July 4' => [{ start: '2000-06-01', end: '2000-07-04', tags: %i[inclusive_range] }],
    'June 1- July 4, 2000' => [{ start: '2000-06-01', end: '2000-07-04', tags: %i[inclusive_range] }],
    '2000 May 5, June 2, 9-23' => [
      { start: '2000-05-05', end: '2000-05-05', tags: %i[multi_date] },
      { start: '2000-06-02', end: '2000-06-02', tags: %i[multi_date] },
      { start: '2000-06-09', end: '2000-06-23', tags: %i[inclusive_range multi_date] }],
    '2000 May -June' => [{ start: '2000-05-01', end: '2000-06-30', tags: %i[inclusive_range month_year] }],
    'May - June 2000' => [{ start: '2000-05-01', end: '2000-06-30', tags: %i[inclusive_range month_year] }],
    '2000 June 3 - 2001 Jan 20' => [{ start: '2000-06-03', end: '2001-01-20', tags: %i[inclusive_range] }],
    '2000 June 3-2001 Jan 20' => [{ start: '2000-06-03', end: '2001-01-20', tags: %i[inclusive_range] }],
    '2000 June 3- 2001 Jan 20' => [{ start: '2000-06-03', end: '2001-01-20', tags: %i[inclusive_range] }],
    '2000 June 1, 2-5, 8, 9' => [
      { start: '2000-06-01', end: '2000-06-01', tags: %i[multi_date] },
      { start: '2000-06-02', end: '2000-06-05', tags: %i[inclusive_range multi_date] },
      { start: '2000-06-08', end: '2000-06-08', tags: %i[multi_date] },
      { start: '2000-06-09', end: '2000-06-09', tags: %i[multi_date] }],
    '2000 June 1, 2-5, 8, and 9' => [
      { start: '2000-06-01', end: '2000-06-01', tags: %i[multi_date] },
      { start: '2000-06-02', end: '2000-06-05', tags: %i[inclusive_range multi_date] },
      { start: '2000-06-08', end: '2000-06-08', tags: %i[multi_date] },
      { start: '2000-06-09', end: '2000-06-09', tags: %i[multi_date] }],
    '2000-01-00-2001-03-00' => [{ start: '2000-01-01', end: '2000-03-31', tags: %i[inclusive_range month_year] }],
    '2000-01-00 - 2001-03-00' => [{ start: '2000-01-01', end: '2000-03-31', tags: %i[inclusive_range month_year] }],
    '19th century' => [{ start: '1801-01-01', end: '1900-12-31', tags: %i[inclusive_range century] }],
    '19th c.' => [{ start: '1801-01-01', end: '1900-12-31', tags: %i[inclusive_range century] }],
    '19th century ?' => [{ start: '1801-01-01', end: '1900-12-31', tags: %i[inclusive_range century questionable] }],
    '19th century [?]' => [{ start: '1801-01-01', end: '1900-12-31', tags: %i[inclusive_range century questionable] }],
    '[19th century]' => [{ start: '1801-01-01', end: '1900-12-31', tags: %i[inclusive_range century inferred] }],
    '17th or 18th century' => [
      { start: '1601-01-01', end: '1700-12-31', tags: %i[inclusive_range century alternate_dates] },
      { start: '1701-01-01', end: '1800-12-31', tags: %i[inclusive_range century alternate_dates] }],
    'early 19th century' => [{ start: '1801-01-01', end: '1834-12-31', tags: %i[inclusive_range century partial] }],
    'mid 19th century' => [{ start: '1834-01-01', end: '1867-12-31', tags: %i[inclusive_range century partial] }],
    'late 19th century' => [{ start: '1867-01-01', end: '1900-12-31', tags: %i[inclusive_range century partial] }],
    'late 19th c.' => [{ start: '1867-01-01', end: '1900-12-31', tags: %i[inclusive_range century partial] }],
    'early to mid-19th century' => [{ start: nil, end: nil, tags: %i[unparseable] }],
    '1800s' => [{ start: '1800-01-01', end: '1899-12-31', tags: %i[inclusive_range approximate centuries] }],
    '18XX' => [{ start: '1800-01-01', end: '1899-12-31', tags: %i[inclusive_range approximate centuries] }],
    '18uu' => [{ start: '1800-01-01', end: '1899-12-31', tags: %i[inclusive_range approximate centuries] }],
    'late 1800s' => [{ start: '1867-01-01', end: '1899-12-31', tags: %i[inclusive_range approximate centuries partial] }],
  }

  def lex(str)
    lexed = Emendate::Lexer.new(str)
    lexed.tokenize
    lexed
  end

  def tokenize(str)
    tokens = lex(str).map(&:type)
    puts "#{str}\t\t#{tokens.inspect}"
  end

  def parse(str)
    p = Emendate::Parser.new(orig: str, tokens: l = lex(str).tokens)
    p.parse
    p
  end

  def tokenize_examples
    ex = EXAMPLES.keys
    lexed = ex.map{ |str| Emendate.lex(str) }
    tokens = lexed.map{ |t| t.tokens.types }
    ex.zip(tokens)
  end

  def parsed_examples
    ex = EXAMPLES.keys
    parsed = []
    errs = []
    err_strs = []
    ex.each do |str|
      begin
        r = Emendate.parse(str)
      rescue StandardError => e
        err_strs << str
        errs << e
      else
        parsed << r
      end
    end
    tokens = parsed.map{ |t| t.tokens.types }
    ex = ex.reject{ |e| err_strs.include?(e) }
    ex.zip(tokens)
  end

  def example_tokens_by_str
    results = tokenize_examples.sort
    results.each{ |str, tokens| puts "#{str.ljust(example_length)}\t#{tokens.inspect}" }
  end

  def example_tokens_by_token
    results = tokenize_examples.sort_by{ |ex| ex[1] }
    results.each{ |str, tokens| puts "#{tokens.join(' ')}  -- String: #{str}" }
  end

  def parsed_tokens_by_token
    results = parsed_examples.sort_by{ |ex| ex[1] }
    results.each{ |str, tokens| puts "#{tokens.join(' ')}  -- String: #{str}" }
  end

  def example_length
    EXAMPLES.keys.sort_by{ |k| k.length }[-1].length
  end
end
