# frozen_string_literal: true

module Helpers
  extend self

  META = %{
CONVENTIONS USED IN EXAMPLE PATTERNS
# = digit in an unambiguous (given assumptions made) number
00 = literally two zeroes
@ = digit in an ambiguous number (i.e. it's not clear whether it's a month or day, etc.)
MON = abbreviated alphabetical month name
MONTH = alphabetical month name
ERA = BCE, AD, CE, BC, etc.
SEASON = alphabetical season term
ORD = alphabetical ordinal indication, such at st, rd, etc.
lowercase letters = themselves, literally
.,/-&?()[] = themselves, literally (same for spaces)
  }

  EXAMPLES = {
    'unknown' => { pattern: 'unknown', results: [{ start: nil, end: nil, tags: %i[indicates_no_date] }] },
    'undated' => { pattern: 'undated', results: [{ start: nil, end: nil, tags: %i[indicates_no_date] }] },
    'n.d.' => { pattern: 'n.d.', results: [{ start: nil, end: nil, tags: %i[indicates_no_date] }] },
    'nd' => { pattern: 'nd', results: [{ start: nil, end: nil, tags: %i[indicates_no_date] }] },
    '02-03-2020' => { pattern: '@@-@@-####', results: [{ start: '2020-02-03', end: '2020-02-03', tags: %i[ambiguous_day_month option] }] },
    '02-15-2020' => { pattern: '##-##-####', results: [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }] },
    '2/15/2020' => { pattern: '#/##/####', results: [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }] },
    '02/15/2020' => { pattern: '##/##/####', results: [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }] },
    '2020-02-15' => { pattern: '####-##-##', results: [{ start: '2020-02-15', end: '2020-02-15', tags: %i[edtf edtf0] }] },
    '2020/02/15' => { pattern: '####/##/##', results: [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }] },
    'Feb. 15, 2020' => { pattern: 'MON. ##, ####', results: [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }] },
    'Feb 15, 2020' => { pattern: 'MON ##, ####', results: [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }] },
    'Feb 15 2020' => { pattern: 'MON ## ####', results: [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }] },
    'Feb. 15 2020' => { pattern: 'MON. ## ####', results: [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }] },
    'February 15 2020' => { pattern: 'MONTH ## ####', results: [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }] },
    'February 15, 2020' => { pattern: 'MONTH ##, ####', results: [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }] },  
    '15 February 2020' => { pattern: '## MONTH ####', results: [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }] },
    '2020 February 15' => { pattern: '#### MONTH ##', results: [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }] },
    '2020 Feb 15' => { pattern: '#### MON ##', results: [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }] },
    '20200215' => { pattern: '########', results: [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }] },
    '15 Feb 2020' => { pattern: '## MON ####', results: [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }] },
    '15 Feb. 2020' => { pattern: '## MON. ####', results: [{ start: '2020-02-15', end: '2020-02-15', tags: %i[] }] },
    '02-15-20' => { pattern: '##-##-##', results: [{ start: '2020-02-15', end: '2020-02-15', tags: %i[two_digit_year option] }] },
    '02-10-20' => { pattern: '@@-@@-##', results: [{ start: '2020-02-10', end: '2020-02-10', tags: %i[two_digit_year option ambiguous_day_month] }] },
    '1/2/2000 - 12/21/2001' => { pattern: '@/@/#### - ##/##/####', results: [{ start: '2000-01-02', end: '2001-12-21', tags: %i[inclusive_range] }] },
    'VIII.XIV.MMXX' => { pattern: 'VIII.XIV.MMXX', results: [{ start: nil, end: nil, tags: %i[unparseable] }] },
    'March 2020' => { pattern: 'MONTH ####', results: [{ start: '2020-03-01', end: '2020-03-31', tags: %i[] }] },
    '2020 Mar' => { pattern: '#### MON', results: [{ start: '2020-03-01', end: '2020-03-31', tags: %i[] }] },
    '2020-03' => { pattern: '####-##', results: [{ start: '2020-03-01', end: '2020-03-31', tags: %i[edtf edtf0 ba] }] },
    '2020-3' => { pattern: '####-#', results: [{ start: '2020-03-01', end: '2020-03-31', tags: %i[] }] },
    '2002' => { pattern: '####', results: [{ start: '2002-01-01', end: '2002-12-31', tags: %i[edtf edtf0 ba] }] },
    '-2002' => { pattern: '-####', results: [{ start: '-2002-01-01', end: '-2002-12-31', tags: %i[edtf edtf1] }] },
    '2002 C.E.' => { pattern: '#### ERA', results: [{ start: '2002-01-01', end: '2002-12-31', tags: %i[] }] },    
    '2002 B.C.E.' => { pattern: '#### ERA', results: [{ start: '-2002-01-01', end: '-2002-12-31', tags: %i[bce] }] },
    '2002?' => { pattern: '####?', results: [{ start: '2002-01-01', end: '2002-12-31', tags: %i[edtf edtf1 uncertain ba] }] },
    '2002-2005 (?)' => { pattern: '####-#### (?)', results: [{ start: '2002-01-01', end: '2005-12-31', tags: %i[uncertain inclusive_range ba] }] },
    '2002 (?)' => { pattern: '#### (?)', results: [{ start: '2002-01-01', end: '2002-12-31', tags: %i[uncertain ba] }] },
    '[2002?]' => { pattern: '[####?]', results: [{ start: '2002-01-01', end: '2002-12-31', tags: %i[inferred uncertain] }] },
    '1997-1998' => { pattern: '####-####', results: [{ start: '1997-01-01', end: '1998-12-31', tags: %i[inclusive_range ba] }] },
    '[1997]-[1998]' => { pattern: '[####]-[####]', results: [{ start: '1997-01-01', end: '1998-12-31', tags: %i[inclusive_range inferred] }] },
    '1997-1998 A.D.' => { pattern: '####-#### ERA', results: [{ start: '1997-01-01', end: '1998-12-31', tags: %i[inclusive_range] }] },
    '450 BCE - 200 BCE' => { pattern: '### ERA - ### ERA', results: [{ start: '-0449-01-01', end: '-0199-12-31', tags: %i[inclusive_range bce] }] },    
    '450 BCE - 200 CE' => { pattern: '### ERA - ### ERA', results: [{ start: '-0449-01-01', end: '0200-12-31', tags: %i[inclusive_range bce cross_era] }] },
    '450 to 200 BCE' => { pattern: '### to ### ERA', results: [{ start: '-0449-01-01', end: '-0199-12-31', tags: %i[inclusive_range bce] }] },    
    '[1997-1998]' => { pattern: '[####-####]', results: [{ start: '1997-01-01', end: '1998-12-31', tags: %i[inclusive_range inferred ba] }] },    
    '1997/98' => { pattern: '####/##', results: [{ start: '1997-01-01', end: '1998-12-31', tags: %i[inclusive_range option] }] },
    '1997-98' => { pattern: '####-##', results: [{ start: '1997-01-01', end: '1998-12-31', tags: %i[inclusive_range option ba] }] },
    '1935, 1946-1947' => { pattern: '####, ####-####', results: [
      { start: '1935-01-01', end: '1935-12-31', tags: %i[multi_date] },
      { start: '1946-01-01', end: '1947-12-31', tags: %i[inclusive_range multi_date] }] },
    '1997 or 1999' => { pattern: '#### or ####', results: [
      { start: '1997-01-01', end: '1997-12-31', tags: %i[alternate_dates ba] },
      { start: '1999-01-01', end: '1999-12-31', tags: %i[alternate_dates ba] }] },
    '[1997 or 1999]' => { pattern: '[#### or ####]', results: [
      { start: '1997-01-01', end: '1997-12-31', tags: %i[alternate_dates inferred ba] },
      { start: '1999-01-01', end: '1999-12-31', tags: %i[alternate_dates inferred ba] }] },
    '1997 & 1999' => { pattern: '#### & ####', results: [
      { start: '1997-01-01', end: '1997-12-31', tags: %i[alternate_dates] },
      { start: '1999-01-01', end: '1999-12-31', tags: %i[alternate_dates] }] },
    'before 1750' => { pattern: 'before ####', results: [{ start: '0001-01-01', end: '1750-01-01', tags: %i[after_before ba] }] },    
    '../1985-04-12' => { pattern: '../####-@@-@@', results: [{ start: '0001-01-01', end: '1985-04-12', tags: %i[after_before open_start] }] },    
    '[..1760-12-03]' => { pattern: '[..####-##-##]', results: [{ start: '0001-01-01', end: '1760-12-02', tags: %i[after_before alternate_date edtf edtf2] }, { start: '1760-12-03', end: '1760-12-03', tags: %i[after_before alternate_date edtf edtf2] }] },
    '[1760-12..]' => { pattern: '[####-##..]', results: [{ start: '1760-12-01', end: '1760-12-31', tags: %i[after_before alternate_date edtf edtf2] }, { start: '1761-01-01', end: Date.today.iso8601, tags: %i[after_before alternate_date edtf edtf2] }] },
    '[1760-01,1760-02,1760-12..]' => { pattern: '[####-##,####-##,####-##..]', results: [{ start: '1760-01-01', end: '1760-01-31', tags: %i[after_before alternate_date edtf edtf2] }, { start: '1760-02-01', end: '1760-02-29', tags: %i[after_before alternate_date edtf edtf2] }, { start: '1761-01-01', end: Date.today.iso8601, tags: %i[after_before alternate_date edtf edtf2] }] },
    '1828-30, 1849-51' => { pattern: '[####-@@, ####-##]', results: [{ start: '1828-01-01', end: '1830-12-31', tags: %i[ambiguous_year_month ba multi_date inclusive_range] }, { start: '1849-01-01', end: '1851-12-31', tags: %i[ba multi_date inclusive_range] }] },
    '[1667,1760-12]' => { pattern: '[####,####-##]', results: [{ start: '1667-01-01', end: '1667-12-31', tags: %i[after_before alternate_date edtf edtf2] }, { start: '1760-12-01', end: '1760-12-31', tags: %i[after_before alternate_date edtf edtf2] }] },
    '[..1984]' => { pattern: '[..####]', results: [{ start: '0001-01-01', end: '1983-12-31', tags: %i[after_before alternate_date edtf edtf2] }, { start: '1984-01-01', end: '1984-12-31', tags: %i[after_before alternate_date edtf edtf2] }] },
    '../1985-04' => { pattern: '../####-##', results: [{ start: '0001-01-01', end: '1985-04-30', tags: %i[after_before open_start] }] },    
    '../1985' => { pattern: '../####', results: [{ start: '0001-01-01', end: '1985-12-31', tags: %i[after_before open_start] }] },    
    '/1985-04-12' => { pattern: '/####-@@-@@', results: [{ start: '0001-01-01', end: '1985-04-12', tags: %i[after_before unknown_start] }] },    
    '/1985-04' => { pattern: '/####-##', results: [{ start: '0001-01-01', end: '1985-04-30', tags: %i[after_before unknown_start] }] },    
    '/1985' => { pattern: '/####', results: [{ start: '0001-01-01', end: '1985-12-31', tags: %i[after_before unknown_start] }] },    
    'after 1815' => { pattern: 'after ####', results: [{ start: '1815-12-31', end: Date.today.iso8601, tags: %i[after_before ba] }] },
    '1985-04-12/..' => { pattern: '####-##-##/..', results: [{ start: '1985-@@-@@', end: Date.today.iso8601, tags: %i[after_before edtf edtf1 open_end] }] },
    '1985-04/..' => { pattern: '####-##/..', results: [{ start: '1985-04-01', end: Date.today.iso8601, tags: %i[after_before edtf edtf1 open_end] }] },
    '1985/..' => { pattern: '####/..', results: [{ start: '1985-01-01', end: Date.today.iso8601, tags: %i[after_before edtf edtf1 open_end] }] },
    '1985-04-12/' => { pattern: '####-##-##/', results: [{ start: '1985-@@-@@', end: Date.today.iso8601, tags: %i[after_before edtf edtf1 unknown_end] }] },
    '1985-04/' => { pattern: '####-##/', results: [{ start: '1985-04-01', end: Date.today.iso8601, tags: %i[after_before edtf edtf1 unknown_end] }] },
    '1985/' => { pattern: '####/', results: [{ start: '1985-01-01', end: Date.today.iso8601, tags: %i[after_before edtf edtf1 unknown_end] }] },
    'circa 2002' => { pattern: 'circa ####', results: [{ start: '2002-01-01', end: '2002-12-31', tags: %i[approximate] }] },
    '[circa 2002?]' => { pattern: '[circa ####?]', results: [{ start: '2002-01-01', end: '2002-12-31', tags: %i[approximate inferred uncertain] }] },
    'c. 2002' => { pattern: 'c. ####', results: [{ start: '2002-01-01', end: '2002-12-31', tags: %i[approximate] }] },
    'c 2002' => { pattern: 'c ####', results: [{ start: '2002-01-01', end: '2002-12-31', tags: %i[approximate] }] },
    'c2002' => { pattern: 'c####', results: [{ start: '2002-01-01', end: '2002-12-31', tags: %i[approximate ba] }] },
    'c. 1997-1998' => { pattern: 'c. ####-####', results: [{ start: '1997-01-01', end: '1998-12-31', tags: %i[inclusive_range approximate] }] },
    'ca. 2002' => { pattern: 'ca. ####', results: [{ start: '2002-01-01', end: '2002-12-31', tags: %i[approximate ba] }] },
    'ca 2002' => { pattern: 'ca ####', results: [{ start: '2002-01-01', end: '2002-12-31', tags: %i[approximate] }] },
    'ca. 1997-1998' => { pattern: 'ca. ####-####', results: [{ start: '1997-01-01', end: '1998-12-31', tags: %i[inclusive_range approximate] }] },
    '[ca. 2002]' => { pattern: '[ca. ####]', results: [{ start: '2002-01-01', end: '2002-12-31', tags: %i[approximate inferred ba] }] },
    '[ca. 2000s]' => { pattern: '[ca. ####]', results: [{ start: '2000-01-01', end: '2009-12-31', tags: %i[approximate inferred inclusive_range ba] }] },
    '[c. 2002]' => { pattern: '[ca. ####]', results: [{ start: '2002-01-01', end: '2002-12-31', tags: %i[approximate inferred ba] }] },    '[ca. 2002-10]' => { pattern: '[ca. ####-@@]', results: [{ start: '2002-01-01', end: '2010-12-31', tags: %i[approximate inferred ambiguous_year_month_season option ba] }] },
    'ca. 1980s & 1990s' => { pattern: 'ca. ####s & ####s', results: [
      { start: '1980-01-01', end: '1989-12-31', tags: %i[inclusive_range approximate multi_date decades ba] },
      { start: '1990-01-01', end: '1999-12-31', tags: %i[inclusive_range approximate multi_date decades ba] }] },
    '2001-01-01, 2002-02-02, 2003-03-03' => { pattern: '####-##-##, ####-##-##, ####-##-##', results: [
      { start: '2001-01-01', end: '2001-01-01', tags: %i[multi_date] },
      { start: '2002-02-02', end: '2002-02-02', tags: %i[multi_date] },
      { start: '2003-03-03', end: '2003-03-03', tags: %i[multi_date] }] },
    '2000-01-01 or 2000-01-12' => { pattern: '####-##-## or ####-##-##', results: [
      { start: '2000-01-01', end: '2000-01-01', tags: %i[alternate_dates] },
      { start: '2000-01-12', end: '2000-01-12', tags: %i[alternate_dates] }] },
    '1990s' => { pattern: '####s', results: [{ start: '1990-01-01', end: '1999-12-31', tags: %i[inclusive_range approximate decades ba] }] },
    '199X' => { pattern: '###x', results: [{ start: '1990-01-01', end: '1999-12-31', tags: %i[inclusive_range approximate decades edtf edtf1] }] },
    '199u' => { pattern: '###u', results: [{ start: '1990-01-01', end: '1999-12-31', tags: %i[inclusive_range approximate decades] }] },
    '1980s or 1990s' => { pattern: '####s or ####s', results: [
      { start: '1980-01-01', end: '1989-12-31', tags: %i[inclusive_range approximate alternate_dates decades] },
      { start: '1990-01-01', end: '1999-12-31', tags: %i[inclusive_range approximate alternate_dates decades] }] },
    '1980s & 1990s' => { pattern: '####s & ####s', results: [
      { start: '1980-01-01', end: '1989-12-31', tags: %i[inclusive_range approximate alternate_dates decades] },
      { start: '1990-01-01', end: '1999-12-31', tags: %i[inclusive_range approximate alternate_dates decades] }] },
    'Early 1990s' => { pattern: 'early ####s', results: [{ start: '1990-01-01', end: '1995-12-31', tags: %i[inclusive_range approximate partial decades] }] },
    'Mid 1990s' => { pattern: 'mid ####s', results: [{ start: '1993-01-01', end: '1998-12-31', tags: %i[inclusive_range approximate partial decades] }] },    
    'Late 1990s' => { pattern: 'late ####s', results: [{ start: '1995-01-01', end: '1999-12-31', tags: %i[inclusive_range approximate partial decades] }] },
    'Early 1990' => { pattern: 'early ####', results: [{ start: '1990-01-01', end: '1990-04-30', tags: %i[inclusive_range approximate partial] }] },
    'Mid 1990' => { pattern: 'mid ####', results: [{ start: '1990-05-01', end: '1990-08-31', tags: %i[inclusive_range approximate partial] }] },    
    'Late 1990' => { pattern: 'late ####', results: [{ start: '1990-09-01', end: '1990-12-31', tags: %i[inclusive_range approximate partial] }] },
    'Spring 2020' => { pattern: 'SEASON ####', results: [{ start: '2020-04-01', end: '2020-06-30', tags: %i[inclusive_range season] }] },
    '2020 Spring' => { pattern: '#### SEASON', results: [{ start: '2020-04-01', end: '2020-06-30', tags: %i[inclusive_range season] }] },
    '2020-21' => { pattern: '####-@@', results: [{ start: '2020-01-01', end: '2021-12-31', tags: %i[edtf edtf1 inclusive_range season two_digit_year ambiguous_year_month_season option] }],
                  alt_results: [{ start: '2020-04-01', end: '2020-06-30', tags: %i[edtf edtf1 inclusive_range season two_digit_year ambiguous_year_month_season option] }]},
    '2020-34' => { pattern: '####-@@', results: [{ start: '2020-01-01', end: '2021-03-31', tags: %i[edtf edtf2 inclusive_range season two_digit_year ambiguous_year_month_season option] }],
                  alt_results: [{ start: '2020-04-01', end: '2020-06-30', tags: %i[edtf edtf1 inclusive_range season two_digit_year ambiguous_year_month_season option] }]},
    'Spring 20' => { pattern: 'SEASON ##', results: [{ start: '2020-04-01', end: '2020-06-30', tags: %i[inclusive_range season two_digit_year option] }],
                    alt_results: [{ start: '0020-04-01', end: '0020-06-30', tags: %i[inclusive_range season two_digit_year option] }]},
    '2000 June 3-15' => { pattern: '#### MONTH #-##', results: [{ start: '2020-06-03', end: '2020-06-15', tags: %i[inclusive_range] }] },
    'June 3-15, 2000' => { pattern: 'MONTH #-##, ####', results: [{ start: '2020-06-03', end: '2020-06-15', tags: %i[inclusive_range] }] },    
    'June 3 -15, 2000' => { pattern: 'MONTH # -##, ####', results: [{ start: '2020-06-03', end: '2020-06-15', tags: %i[inclusive_range] }] },
    '2000 June 3, 15' => { pattern: '#### MONTH #, #', results: [
      { start: '2000-06-03', end: '2000-06-03', tags: %i[multi_date] },
      { start: '2000-06-15', end: '2000-06-15', tags: %i[multi_date] }] },
    '2000 June 1-July 4' => { pattern: '#### MONTH #-MONTH #', results: [{ start: '2000-06-01', end: '2000-07-04', tags: %i[inclusive_range] }] },
    'June 1- July 4, 2000' => { pattern: 'MONTH #- MONTH #, ####', results: [{ start: '2000-06-01', end: '2000-07-04', tags: %i[inclusive_range] }] },
    '2000 May 5, June 2, 9-23' => { pattern: '#### MONTH #, MONTH #, #-##', results: [
      { start: '2000-05-05', end: '2000-05-05', tags: %i[multi_date] },
      { start: '2000-06-02', end: '2000-06-02', tags: %i[multi_date] },
      { start: '2000-06-09', end: '2000-06-23', tags: %i[inclusive_range multi_date] }] },
    '2000 May -June' => { pattern: '#### MONTH -MONTH', results: [{ start: '2000-05-01', end: '2000-06-30', tags: %i[inclusive_range ] }] },
    'May - June 2000' => { pattern: 'MONTH - MONTH ####', results: [{ start: '2000-05-01', end: '2000-06-30', tags: %i[inclusive_range ] }] },
    '2000 June 3 - 2001 Jan 20' => { pattern: '#### MONTH # - #### MON ##', results: [{ start: '2000-06-03', end: '2001-01-20', tags: %i[inclusive_range] }] },
    '2000 June 3-2001 Jan 20' => { pattern: '#### MONTH #-#### MON ##', results: [{ start: '2000-06-03', end: '2001-01-20', tags: %i[inclusive_range] }] },
    '2000 June 3- 2001 Jan 20' => { pattern: '#### MONTH #- #### MON ##', results: [{ start: '2000-06-03', end: '2001-01-20', tags: %i[inclusive_range] }] },
    '2000 June 1, 2-5, 8, 9' => { pattern: '#### MONTH #, #-#, #, #', results: [
      { start: '2000-06-01', end: '2000-06-01', tags: %i[multi_date] },
      { start: '2000-06-02', end: '2000-06-05', tags: %i[inclusive_range multi_date] },
      { start: '2000-06-08', end: '2000-06-08', tags: %i[multi_date] },
      { start: '2000-06-09', end: '2000-06-09', tags: %i[multi_date] }] },
    '2000 June 1, 2-5, 8, and 9' => { pattern: '#### MONTH #, #-#, #, and #', results: [
      { start: '2000-06-01', end: '2000-06-01', tags: %i[multi_date] },
      { start: '2000-06-02', end: '2000-06-05', tags: %i[inclusive_range multi_date] },
      { start: '2000-06-08', end: '2000-06-08', tags: %i[multi_date] },
      { start: '2000-06-09', end: '2000-06-09', tags: %i[multi_date] }] },
    '2000-01-00-2001-03-00' => { pattern: '####-##-00-####-##-00', results: [{ start: '2000-01-01', end: '2000-03-31', tags: %i[inclusive_range ] }] },
    '2000-01-00 - 2001-03-00' => { pattern: '####-##-00 - ####-##-00', results: [{ start: '2000-01-01', end: '2000-03-31', tags: %i[inclusive_range ] }] },
    '19th-20th century' => { pattern: '[##ORD-##ORD century]', results: [{ start: '1801-01-01', end: '2000-12-31', tags: %i[ba century inclusive_range] }] },
    '19th century' => { pattern: '##ORD century', results: [{ start: '1801-01-01', end: '1900-12-31', tags: %i[inclusive_range century] }] },
    '19th c.' => { pattern: '##ORD c.', results: [{ start: '1801-01-01', end: '1900-12-31', tags: %i[inclusive_range century ba] }] },
    '19th century ?' => { pattern: '##ORD century ?', results: [{ start: '1801-01-01', end: '1900-12-31', tags: %i[inclusive_range century uncertain] }] },
    '19th century [?]' => { pattern: '##ORD century [?]', results: [{ start: '1801-01-01', end: '1900-12-31', tags: %i[inclusive_range century uncertain] }] },
    '[19th century]' => { pattern: '[##ORD century]', results: [{ start: '1801-01-01', end: '1900-12-31', tags: %i[inclusive_range century inferred ba] }] },
    '17th or 18th century' => { pattern: '##ORD or ##ORD century', results: [
      { start: '1601-01-01', end: '1700-12-31', tags: %i[inclusive_range century alternate_dates] },
      { start: '1701-01-01', end: '1800-12-31', tags: %i[inclusive_range century alternate_dates] }] },
    'early 19th century' => { pattern: 'early ##ORD century', results: [{ start: '1801-01-01', end: '1834-12-31', tags: %i[inclusive_range century partial ba] }] },
    'mid-19th century' => { pattern: 'mid-##ORD century', results: [{ start: '1834-01-01', end: '1867-12-31', tags: %i[inclusive_range century partial] }] },
    'late 19th century' => { pattern: 'late ##ORD century', results: [{ start: '1867-01-01', end: '1900-12-31', tags: %i[inclusive_range century partial ba] }] },
    'late 19th to early 20th century' => { pattern: 'late ##ORD to early ##ORD century', results: [{ start: '1867-01-01', end: '1934-12-31', tags: %i[inclusive_range century partial ba] }] },
    'late 19th-early 20th c.' => { pattern: 'late ##ORD-early ##ORD century', results: [{ start: '1867-01-01', end: '1934-12-31', tags: %i[inclusive_range century partial ba] }] },    
    'late 19th c.' => { pattern: 'late ##ORD c.', results: [{ start: '1867-01-01', end: '1900-12-31', tags: %i[inclusive_range century partial ba] }] },
    'early to mid-19th century' => { pattern: 'early to mid-##ORD century', results: [{ start: nil, end: nil, tags: %i[unparseable ba] }] },
    '1800s' => { pattern: '####s', results: [{ start: '1800-01-01', end: '1899-12-31', tags: %i[inclusive_range approximate centuries ba] }] },
    '18XX' => { pattern: '##xx', results: [{ start: '1800-01-01', end: '1899-12-31', tags: %i[inclusive_range approximate centuries edtf edtf1] }] },
    '18uu' => { pattern: '##uu', results: [{ start: '1800-01-01', end: '1899-12-31', tags: %i[inclusive_range approximate centuries] }] },
    '1uuu' => { pattern: '#uuu', results: [{ start: '1000-01-01', end: '1999-12-31', tags: %i[inclusive_range approximate millennia] }] },
    'late 1800s' => { pattern: 'late ####s', results: [{ start: '1867-01-01', end: '1899-12-31', tags: %i[inclusive_range approximate centuries partial] }] },
    '1985-04-12T23:20:30Z' => { pattern: '####-##-##t##:##:##z', results: [{ start: '1985-04-12', end: '1985-04-12', tags: %i[edtf edtf0 time] }] },
    '1985-04-12T23:20:30' => { pattern: '####-##-##t##:##:##', results: [{ start: '1985-04-12', end: '1985-04-12', tags: %i[edtf edtf0 time] }] },
    '1985-04-12T23:20:30-04' => { pattern: '####-##-##t##:##:##-##', results: [{ start: '1985-04-12', end: '1985-04-12', tags: %i[edtf edtf0 time] }] },
    '1985-04-12T23:20:30+04:30' => { pattern: '####-##-##t##:##:##+##:##', results: [{ start: '1985-04-12', end: '1985-04-12', tags: %i[edtf edtf0 time] }] },
    '1964/2008' => { pattern: '####/####', results: [{ start: '1964-01-01', end: '2008-12-31', tags: %i[edtf edtf0 inclusive_range] }] },
    '2004-02-01/2005-02-08' => { pattern: '####-##-##/####-##-##', results: [{ start: '2004-02-01', end: '2005-02-08', tags: %i[edtf edtf0 inclusive_range] }] },
    '2004-02-01/2005-02' => { pattern: '####-##-##/####-##', results: [{ start: '2004-02-01', end: '2005-02-28', tags: %i[edtf edtf0 inclusive_range] }] },
    '2004-02-01/2005' => { pattern: '####-##-##/####', results: [{ start: '2004-02-01', end: '2005-12-31', tags: %i[edtf edtf0 inclusive_range] }] },
    'Y170002' => { pattern: 'y######', results: [{ start: '170002-01-01', end: '170002-12-31', tags: %i[edtf edtf1 letter_prefixed_year] }] },
    'Y-170002' => { pattern: 'y-######', results: [{ start: '-170002-01-01', end: '-170002-12-31', tags: %i[edtf edtf1 letter_prefixed_year] }] },
    '2004-06~' => { pattern: '####-@@~', results: [{ start: '2004-06-01', end: '2004-06-30', tags: %i[edtf edtf1 approximate] }] },
    '2004-06%' => { pattern: '####-@@%', results: [{ start: '2004-06-01', end: '2004-06-30', tags: %i[edtf edtf1 uncertain_and_approximate] }] },
    '2004-XX' => { pattern: '####-xx', results: [{ start: '2004-01-01', end: '2004-12-31', tags: %i[edtf edtf1 uncertainty_digits] }] },
    '2004-XX-XX' => { pattern: '####-xx-xx', results: [{ start: '2004-01-01', end: '2004-12-31', tags: %i[edtf edtf1 uncertainty_digits] }] },
    '1985-04-XX' => { pattern: '####-##-xx', results: [{ start: '1985-04-01', end: '1985-04-30', tags: %i[edtf edtf1 uncertainty_digits] }] },
    'Y-17E7' => { pattern: 'y-##e#', results: [{ start: nil, end: nil, tags: %i[edtf edtf2 currently_unparseable exponential_year] }] },
    '1950S2' => { pattern: '####s#', results: [{ start: nil, end: nil, tags: %i[edtf edtf2 currently_unparseable significant_digits] }] },
    'Y171010000S3' => { pattern: 'y#########s#', results: [{ start: nil, end: nil, tags: %i[edtf edtf2 currently_unparseable significant_digits letter_prefixed_year] }] },
    '[1667,1668,1670..1672]' => { pattern: '[####,####,####..####]', results: [{ start: '1667-01-01', end: '1667-12-31', tags: %i[edtf edtf2 alternate_dates] }, { start: '1668-01-01', end: '1668-12-31', tags: %i[edtf edtf2 alternate_dates] }, { start: '1670-01-01', end: '1670-12-31', tags: %i[edtf edtf2 alternate_dates] }, { start: '1671-01-01', end: '1671-12-31', tags: %i[edtf edtf2 alternate_dates] }, { start: '1672-01-01', end: '1672-12-31', tags: %i[edtf edtf2 alternate_dates] }] },
    '{1667,1668,1670..1672}' => { pattern: '{####,####,####..####}', results: [{ start: '1667-01-01', end: '1667-12-31', tags: %i[edtf edtf2 multi_dates] }, { start: '1668-01-01', end: '1668-12-31', tags: %i[edtf edtf2 multi_dates] }, { start: '1670-01-01', end: '1670-12-31', tags: %i[edtf edtf2 multi_dates] }, { start: '1671-01-01', end: '1671-12-31', tags: %i[edtf edtf2 multi_dates] }, { start: '1672-01-01', end: '1672-12-31', tags: %i[edtf edtf2 multi_dates] }] },
    '{1960,1961-12}' => { pattern: '{####,####-##}', results: [{ start: '1960-01-01', end: '1960-12-31', tags: %i[edtf edtf2 multi_dates] }, { start: '1961-12-01', end: '1961-12-31', tags: %i[edtf edtf multi_dates] }] },
    '{..1984}' => { pattern: '{..####}', results: [{ start: '0001-01-01', end: '1983-12-31', tags: %i[edtf edtf2 multi_dates] }, { start: '1984-01-01', end: '1984-12-31', tags: %i[edtf edtf multi_dates] }] },
    '2004-06-11%' => { pattern: '####-##-##%', results: [{ start: '2004-06-01', end: '2004-06-01', tags: %i[edtf edtf2 uncertain_and_approximate] }] },
    '2004-06~-11' => { pattern: '####-##~-##', results: [{ start: '2004-06-01', end: '2004-06-01', tags: %i[edtf edtf2 year_and_month_approximate] }] },
    '2004?-06-11' => { pattern: '####?-##-##', results: [{ start: '2004-06-01', end: '2004-06-01', tags: %i[edtf edtf2 year_uncertain] }] },
    '?2004-06-~11' => { pattern: '?####-##-~##', results: [{ start: '2004-06-01', end: '2004-06-01', tags: %i[edtf edtf2 year_uncertain day_approximate] }] },
    '2004-%06-11' => { pattern: '####-%##-##', results: [{ start: '2004-06-01', end: '2004-06-01', tags: %i[edtf edtf2 month_uncertain_and_approximate] }] },
    '156X-12-25' => { pattern: '###x-##-##', results: [{ start: nil, end: nil, tags: %i[edtf edtf2 currently_unparseable specific_date_in_range_of_years] }] },
    '15XX-12-25' => { pattern: '##xx-##-##', results: [{ start: nil, end: nil, tags: %i[edtf edtf2 currently_unparseable specific_date_in_range_of_years] }] },
    'XXXX-12-XX' => { pattern: 'xxxx-##-xx', results: [{ start: nil, end: nil, tags: %i[edtf edtf2 currently_unparseable in_specific_month_in_any_year] }] },
    '1XXX-12' => { pattern: '#xxx-##', results: [{ start: nil, end: nil, tags: %i[edtf edtf2 currently_unparseable in_specific_month_in_any_year] }] },
    '1XXX-XX' => { pattern: '#xxx-xx', results: [{ start: nil, end: nil, tags: %i[edtf edtf2 currently_unparseable in_specific_month_in_any_year] }] },
    '1984-1X' => { pattern: '####-#x', results: [{ start: '1984-10-01', end: '1984-12-31', tags: %i[edtf edtf2 uncertainty_digits_month] }] },
    '2004-06-~01/2004-06-~20' => { pattern: '####-##-~##/####-##-~##', results: [{ start: '2004-06-01', end: '2004-06-20', tags: %i[edtf edtf2 approximate_handling_todo inclusive_range] }] },
    '2004-06-XX/2004-07-03' => { pattern: '####-##-xx/####-##-##', results: [{ start: '2004-06-01', end: '2004-07-03', tags: %i[edtf edtf2 inclusive_range] }] },

    # The following examples aren't getting handled correctly and cause `example_results` to fail
    #    '2004-06/2006-08' => { pattern: '####-##/####-##', results: [{ start: '2004-06-01', end: '2006-08-31', tags: %i[edtf edtf0 inclusive_range] }] },
    # this example makes no sense without the option set to non-default on the first value,
    #  but we're representing default expectations here
    # '2000-01, 2001-01, 2002-02, 2003-03' => { pattern: '####-@@, ####-##, ####-##, ####-##', results: [
    #   { start: '2000-01-01', end: '2001-12-31', tags: %i[ambiguous_multi_date  option] },
    #   { start: '2001-01-01', end: '2001-01-31', tags: %i[ambiguous_multi_date ] },
    #   { start: '2002-02-01', end: '2002-02-28', tags: %i[ambiguous_multi_date ] },
    #   { start: '2003-03-01', end: '2003-03-31', tags: %i[ambiguous_multi_date ] }] },

    # the following example lexes fine if you do it manually/individually, but gets stuck/hands in some kind of loop when
    #   run via unique_token_patterns
    #'Y3388E2S3' => { pattern: 'y####e#s#', results: [{ start: nil, end: nil, tags: %i[edtf edtf2 currently_unparseable significant_digits letter_prefixed_year exponential_year] }] }
  }

  def example_tags
    EXAMPLES.map{ |str, exhash| [str, exhash[:results]] }
      .to_h
      .map{ |str, arr| [str, arr.map{ |result| result[:tags] }.flatten.uniq] }
      .to_h
  end
  
  def examples_with_tag(tag)
    example_tags.keep_if{ |str, tags| tags.include?(tag) }.keys
  end
  
  def tokenize_examples
    ex = EXAMPLES.keys
    lexed = ex.map{ |str| Emendate.lex(str) }
    tokens = lexed.map{ |t| t.tokens.types }
    ex.zip(tokens)
  end

  def parse_examples(tag: nil, stage: nil, options: {})
    ex = tag.nil? ? EXAMPLES.keys : examples_with_tag(tag)
    # for regular use
    if stage.nil?
      ex.map{ |str| Emendate.process(str, options) }
    else
      ex.map{ |str| Emendate.prep_for(str, stage, options) }
    end
  end

  # stage should be a SegmentSet-holding instance variable of ProcessingManager
  def parsed_example_tokens(type: :all, stage: nil, tag: nil, options: {})
    parsed = parse_examples(tag: tag, stage: stage, options: options).reject{ |pm| pm.state == :failed }
    processed = parsed.map(&:tokens)
    tokens = type == :date ? processed.map(&:date_part_types) : processed.map(&:types)
    ex = parsed.map{ |pm| pm.orig_string }
    ex.zip(tokens)
  end

  def failed_to_parse(tag: nil)
    parsed = parse_examples(tag: tag).select{ |pm| pm.state == :failed }
    parsed.map{ |f| "#{f.orig_string} - #{f.errors.join('; ')}" }
  end

  def example_tokens_by_str
    results = tokenize_examples.sort
    results.each{ |str, tokens| puts "#{str.ljust(example_length)}\t#{tokens.inspect}" }
  end

  def example_tokens_by_token
    results = tokenize_examples.sort_by{ |ex| ex[1] }
    results.each{ |str, tokens| puts "#{tokens.join(' ')}  -- String: #{str}" }
  end

  def parsed_tokens_by_token(type: :all, stage: :final)
    results = parsed_example_tokens(type: type, stage: stage).sort_by{ |ex| ex[1] }
    results.each{ |str, tokens| puts "#{tokens.join(' ')}  -- String: #{str}" }
  end

  # stage should be a SegmentSet-holding instance variable of ProcessingManager
  def unique_type_patterns(type: :all, stage: nil, tag: nil, options: {} )
    results = parsed_example_tokens(type: type, stage: stage, tag: tag, options: options)
    patterns = results.map{ |parsed| parsed[1] }.uniq.sort.map{ |pattern| [pattern, []] }.to_h
    results.each{ |r| patterns[r[1]] << r[0] }
    patterns.keys.sort.each do |pattern|
      puts pattern.join(' ')
      patterns[pattern].each{ |e| puts '     ' + e }
    end

    puts "\n\n PARSING FAILURES"
    puts failed_to_parse(tag: tag)
  end

  def example_results(tag: nil, options: {} )
    parse_examples(tag: tag, options: options).map(&:result)
  end
  
  def example_length
    EXAMPLES.keys.sort_by{ |k| k.length }[-1].length
  end
end
