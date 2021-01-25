require 'date'
require 'pry'

require 'emendate/version'

require 'emendate/number_utils'

require 'emendate/lexer'
require 'emendate/location'
require 'emendate/parser'
require 'emendate/result'
require 'emendate/certainty'
require 'emendate/date_part_tagger'
require 'emendate/date_segmenter'
require 'emendate/date_utils'
require 'emendate/alpha_month_converter'
require 'emendate/parsed_date'
require 'emendate/token'
require 'emendate/token_set'
require 'emendate/ordinal_translator'

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

  def parse(str)
    p = Emendate::Parser.new(orig: str, tokens: l = lex(str).tokens)
    p.parse
    p
  end
end
