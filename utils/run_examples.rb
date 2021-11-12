# frozen_string_literal: true

require 'bundler/setup'
require 'emendate'
require 'pry'

#e = Emendate.examples
e = Emendate.examples(data_set: 'ncm')
e.run_tests
e.group_by_pass_fail[:failures].each{ |test| puts test.full_report }

e.pass_fail_summary
