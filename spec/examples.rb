# frozen_string_literal: true

#   META = %{
# CONVENTIONS USED IN EXAMPLE PATTERNS
# # = digit in an unambiguous (given assumptions made) number
# 0 = literally one zero
# 00 = literally two zeroes
# @ = digit in an ambiguous number (i.e. it's not clear whether it's a month or day, etc.)
# MON = abbreviated alphabetical month name
# MONTH = alphabetical month name
# ERA = BCE, AD, CE, BC, etc.
# SEASON = alphabetical season term
# ORD = alphabetical ordinal indication, such at st, rd, etc.
# lowercase letters = themselves, literally
# .,/-&?()[] = themselves, literally (same for spaces)
#   }

require_relative 'examples/example_set'
require_relative 'examples/row'

module Examples
  extend self
  
  Path = File.expand_path("#{Pathname(__FILE__).dirname.realpath}/support/examples.csv")

  # pass in data_set and/or date_type tags as strings with ; as delimiter
  def examples(data_set: '', date_type: '')
    ExampleSet.new(data_set: data_set.split(';'), date_type: date_type.split(';'))
  end
end






# class TestRowSet
#   attr_reader :string, :pattern
#   def initialize(rows)
#     @rows = rows
#     @string = rows.first['examplestring']
#     @pattern = rows.first['pattern']
#   end
# end
