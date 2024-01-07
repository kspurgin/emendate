# frozen_string_literal: true

require 'forwardable'
require_relative '../location'

module Emendate
  # Mixin providing the logic for deriving one segment from one or more other segments
  # Segments using this module will call `derive(opts)` from their `post_initialize` method
  # Used by: DerivedToken, DatePart
  module DerivedSegment
    def sources
      @sources
    end

    private

    def derive(opts)
      set_sources(opts)
      derive_values
    end

    def derive_values
      if sources.length == 1
        derive_from_single_value
      elsif sources.length > 1
        derive_from_multiple_values
      end
    end

    def derive_from_single_value
      src = sources[0]
      @certainty = src.certainty if certainty.nil? || certainty.empty?
      @lexeme = src.lexeme if lexeme.nil?
      @literal = src.literal if literal.nil?
      @type = src.type if type.nil?
      @location = src.location if location.nil?
    end

    def derive_from_multiple_values
      @lexeme = sources.map(&:lexeme).join('') if lexeme.nil?
      @location = derive_location if location.nil?
      @literal = derive_literal if literal.nil?
    end

    def derive_literal
      literal = sources.map(&:literal)
                       .compact
                       .select{ |val| val.is_a?(Integer) }
                       .join('').strip

      return nil if literal.empty?

      literal.to_i
    end

    def derive_location
      nil
      # start_position = sources[0].location.col
      # length = sources.map{ |src| src.location.length }.sum
      # Emendate::Location.new(start_position, length)
    end

    def set_sources(opts)
      @sources = Emendate::SegmentSets::MixedSet.new
      return if opts[:sources].nil?
      return if opts[:sources].empty?

      srcs = if opts[:sources].respond_to?(:segments)
               opts[:sources].segments
             else
               opts[:sources]
             end

      srcs.map{ |src| subsources(src) }
          .flatten
          .each{ |t| @sources << t }
    end

    def subsources(src)
      return src unless src.respond_to?(:sources)

      src.sources.segments
    end
  end
end
