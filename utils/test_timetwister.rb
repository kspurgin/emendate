#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'emendate'

# it's weird to have bundler setup and inline together, but I don't want timetwister to be a
#   development dependency
require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'timetwister'
end

require 'timetwister'

class TTTest
  attr_reader :string, :expected, :got
  def initialize(string:, expected: nil, got: nil)
    @string = string
    @expected = expected
    @got = got
  end

  def compare
    return if @expected.nil? || @got.nil?
    reportable = []
    unless start_date_match?
      e = vals(expected, :start).map{ |v| v.nil? ? 'nil' : v }.join('; ')
      g = vals(got, :date_start_full).map{ |v| v.nil? ? 'nil' : v }.join('; ')
      reportable << "START - expected: #{e} - got: #{g}"
    end
    unless end_date_match?
      e = vals(expected, :end).map{ |v| v.nil? ? 'nil' : v }.join('; ')
      g = vals(got, :date_end_full).map{ |v| v.nil? ? 'nil' : v }.join('; ')
      reportable << "END - expected: #{e} - got: #{g}"
    end

    reportable.join(' --- ')
  end

  def passes?
    if start_date_match? && end_date_match? && range_match?
      true
    else
      false
    end
  end

  private

  def vals(a, val)
    a.map{ |ex| ex[val] }
  end

  def range_match?
    expected_ranges? == got_ranges? ? true : false
  end

  def expected_ranges?
    expected.map{ |h| h[:tags].include?(:inclusive_range) ? true : nil }
  end

  def got_ranges?
    got.map{ |h| h[:inclusive_range] }
  end

  def start_date_match?
    vals(expected, :start) == vals(got, :date_start_full) ? true : false
  end

  def end_date_match?
    vals(expected, :end) == vals(got, :date_end_full) ? true : false
  end
end

examples = Emendate::EXAMPLES
ex_strings = examples.keys

results = {}
ex_strings.each{ |str| results[str] = Timetwister.parse(str) }

tests = []
examples.each do |string, example|
  tests << TTTest.new(string: string, expected: example, got: results[string])
end

passing = tests.select{ |t| t.passes? }
failing = tests.reject{ |t| t.passes? }

puts "PASSING: #{passing.length}"
puts "FAILING: #{failing.length}"

puts 'failure details:'.upcase
failing.each{ |t| puts "#{t.string} >> #{t.compare}" }
