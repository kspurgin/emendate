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

  def get_month_lookup
    h = {}
    Date::MONTHNAMES.compact.map(&:downcase).each_with_index{ |str, i| h[str] = i + 1 }
    h
  end

  def get_month_abbr_lookup
    h = {}
    Date::ABBR_MONTHNAMES.compact.map(&:downcase).each_with_index{ |str, i| h[str] = i + 1 }
    h
  end
  
  MONTH_LKUP = get_month_lookup.freeze
  MONTH_ABBR_LKUP = get_month_abbr_lookup.freeze

  DATE_PART_TOKEN_TYPES = %i[number1or2 number3 number4 number6 number8 s century
                             uncertainty_digits era number_month]
end
