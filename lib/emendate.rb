# std lib
require 'date'

# dev
require 'pry-byebug'

require 'emendate/version'

#mix ins
require 'emendate/date_utils'
require 'emendate/number_utils' #required before date_utils

require 'emendate/date_types'

require 'emendate/alpha_month_converter'
require 'emendate/certainty'
require 'emendate/date_segmenter'
require 'emendate/format_standardizer'
require 'emendate/lexer'
require 'emendate/location'
require 'emendate/options'
require 'emendate/ordinal_translator'
require 'emendate/parsed_date'
require 'emendate/parser'
require 'emendate/result'
require 'emendate/token'
require 'emendate/token_set'


require_relative '../spec/helpers'

module Emendate
  include Helpers
  extend self

  DATE_PART_TOKEN_TYPES = %i[number1or2 number3 number4 number6 number8 s century
                             uncertainty_digits era number_month]

  def lex(str)
    lexed = Emendate::Lexer.new(str)
    lexed.tokenize
    lexed
  end

  def tokenize(str)
    tokens = lex(str).map(&:type)
    puts "#{str}\t\t#{tokens.inspect}"
  end

  def parse(str, options = {})
    p = Emendate::Parser.new(orig: str, tokens: l = lex(str).tokens, options: options)
    p.parse
    p
  end
end
