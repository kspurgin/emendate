# frozen_string_literal: true

# std lib
require 'date'
require 'fileutils'

# external gems
require 'aasm'
require 'active_support'
require 'active_support/core_ext/object'

require 'emendate/date_types/date_type'
# require 'emendate/segment/segment'

Dir.glob("#{__dir__}/**/*").sort.select { |path| path.match?(/\.rb$/) }.each do |rbfile|
  require rbfile.delete_prefix("#{File.expand_path(__dir__)}/lib/")
end

require_relative '../spec/helpers'

module Emendate
  include Helpers
  extend self

  LQ = "\u201C"
  RQ = "\u201D"

  # these tokens should only appear in EDTF dates, and will switch some of the options
  #  to support assumptions about processing EDTF
  EDTF_TYPES = %i[double_dot percent tilde curly_bracket_open letter_y letter_t letter_z letter_e]

  # str = String to process
  # sym = Symbol of aasm event for which you would use the results as input.
  # For example, running :tag_date_parts requires successful format standardization
  #   To test date part tagging, you can use the results of prep_for(str, :tag_date_parts)
  def prep_for(str, sym, options = {})
    pm = Emendate::ProcessingManager.new(str, options)
    pm.prep_for(sym)
    pm
  end

  def parse(str, options = {})
    pm = Emendate::ProcessingManager.new(str, options)
    pm.process
    pm.result
  end

  def process(str, options = {})
    pm = Emendate::ProcessingManager.new(str, options)
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
end
