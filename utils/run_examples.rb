# frozen_string_literal: true

require 'bundler/setup'
require 'emendate'
require 'pry'

# Emendate.process('Y-170002')
# e = Emendate.process('MXL.VIII')
# e = Emendate.process('1910-11', ambiguous_month_year: :as_year)
# e = Emendate.lex('unk.')
# e = Emendate.prep_for('unk.', :standardized_formats)

# e = Emendate.examples
# e = Emendate.examples(date_type: 'currently_unparseable')
# e = Emendate.examples(data_set: 'ba')
e = Emendate.examples(data_set: 'opt')

e.run_tests
# e.run_tests(test_list: %i[test_processing])

f = e.group_by_pass_fail[:failures]
f.each{ |test| puts test.full_report } if f
e.pass_fail_summary

# ## token types for known unknown dates
# e = Emendate.examples(date_type: 'indicates_no_date')
# s = e.strings
# s.each do |str|
#   lexed = Emendate.lex(str)
#   puts "#{str} : #{lexed.tokens.types.join(', ')}"
# end
