# std lib
require 'date'
require 'fileutils'

# external gems
require 'aasm'

# dev
require 'pry-byebug'

require 'emendate/date_types/date_type'

Dir[File.dirname(__FILE__) + '/../lib/emendate/*.rb'].each do |file| 
  require "emendate/#{File.basename(file, File.extname(file))}"
end
Dir[File.dirname(__FILE__) + '/../lib/emendate/date_types/*.rb'].each do |file| 
  require "emendate/date_types/#{File.basename(file, File.extname(file))}"
end

require_relative '../spec/helpers'

module Emendate
  include Helpers
  extend self

  DATE_PART_TOKEN_TYPES = %i[number1or2 number3 number4 number6 number8 s century
                             uncertainty_digits era number_month]

  LQ = "\u201C"
  RQ = "\u201D"

  def process(str)
    pm = Emendate::ProcessingManager.new(str)
    pm.process
    pm
  end
  
  def lex(str)
    lexed = Emendate::Lexer.new(Emendate.normalize_orig(str))
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
