# frozen_string_literal: true

require "forwardable"

module Emendate
  # Mixin providing the logic for deriving one segment from one or
  # more other segments
  #
  # Segments using this module will call `derive(opts)` from their
  # `post_initialize` method
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
      @digits = src.digits
    end

    def derive_from_multiple_values
      @lexeme = sources.map(&:lexeme).join("") if lexeme.nil?
      @literal = derive_literal if literal.nil?
      @certainty = sources.map(&:certainty).flatten.uniq.sort
      @digits = sources.map(&:digits).compact.sum
    end

    def derive_literal
      literal = sources.map(&:literal).compact
      return nil if literal.empty?

      if literal.any? { |val| val.is_a?(Integer) } &&
          literal.any? { |val| val.is_a?(Symbol) }
        raise Emendate::DerivedSegmentError.new(
          sources, "Cannot derive literal from mixed Integers and Symbols"
        )
      elsif literal.all? { |val| val.is_a?(Integer) }
        literal.select { |val| val.is_a?(Integer) }
          .join("")
          .to_i
      elsif literal.all? { |val| val.is_a?(Symbol) }
        syms = literal.select { |val| val.is_a?(Symbol) }
        case syms.length
        when 1
          syms[0]
        else
          raise Emendate::DerivedSegmentError.new(
            sources, "Cannot derive literal from multiple symbols"
          )
        end
      else
        raise Emendate::DerivedSegmentError.new(
          sources, "Cannot derive literal for unknown reason"
        )
      end
    end

    def set_sources(opts)
      @sources = Emendate::SegmentSets::SegmentSet.new
      return if opts[:sources].nil?
      return if opts[:sources].empty?

      srcs = if opts[:sources].respond_to?(:segments)
        opts[:sources].segments
      else
        opts[:sources]
      end

      srcs.map { |src| subsources(src) }
        .flatten
        .each { |t| @sources << t }
    end

    def subsources(src)
      return src unless src.respond_to?(:sources)

      src.sources.segments
    end
  end
end
