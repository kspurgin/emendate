# frozen_string_literal: true

require 'forwardable'

module Emendate
  module DerivedSegment
    def derive(opts)
      set_sources(opts)
      derive_values if sources.length == 1
    end

    def derive_values
      src = sources[0]
      @certainty = src.certainty if certainty.nil?
      @lexeme = src.lexeme if lexeme.nil?
      @literal = src.literal if literal.nil?
      @type = src.type if type.nil?
    end

    def set_sources(opts)
      @sources = Emendate::MixedSet.new
      return if opts[:sources].nil?
      return if opts[:sources].empty?
      opts[:sources].each{ |t| sources << t }
    end
    
    def sources
      @sources
    end
  end
end
