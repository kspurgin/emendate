# frozen_string_literal: true

module Emendate
  # Mixin methods for qualifiable date type classes, ParsedDate, and
  #   any relevant translators
  module Qualifiable
    # ----------------------------------------------------------------------
    # BOOLEAN INFO ABOUT QUALIFIERS (top level)
    # ----------------------------------------------------------------------

    # @return [TrueClass] if no date-level qualifiers
    # @return [FalseClass] otherwise
    def certain? = qualifiers.empty?

    # @return [TrueClass] if any date-level qualifiers have type =
    #   :approximate
    def approximate? = !q_by_type(:approximate).empty?

    # @return [Boolean]
    def approximate_and_uncertain?
      (approximate? && uncertain?) ||
        qtypes.include?(:approximate_and_uncertain)
    end

    # @return [TrueClass] if any date-level qualifiers have type =
    #   :inferred
    def inferred? = !q_by_type(:inferred).empty?

    # @return [TrueClass] if any date-level qualifiers have type =
    #   :uncertain
    def uncertain? = !q_by_type(:uncertain).empty?

    # ----------------------------------------------------------------------
    # QUALIFIER TYPES (top level)
    # ----------------------------------------------------------------------

    # @return [Array<Symbol>]
    def qtypes = qualifiers.map(&:type)

    # ----------------------------------------------------------------------
    # EXTRACTION OF QUALIFIERS (top level)
    # ----------------------------------------------------------------------

    # @param type [Symbol]
    # @return [Array<Emendate::Qualifier>]
    def q_by_type(type)
      qualifiers.select { |q| q.type == type }
    end

    # @return [Array<Emendate::Qualifier>]
    def approximate_qualifiers = q_by_type(:approximate)

    # @return [Array<Emendate::Qualifier>]
    def approximate_and_uncertain_qualifiers
      [approximate_qualifiers, uncertain_qualifiers].flatten
    end

    # @return [Array<Emendate::Qualifier>]
    def inferred_qualifiers = q_by_type(:inferred)

    # @return [Array<Emendate::Qualifier>]
    def uncertain_qualifiers = q_by_type(:uncertain)

    # ----------------------------------------------------------------------
    # EXTRACTION OF QUALIFIERS (from date part sources)
    # ----------------------------------------------------------------------

    # @param type [Symbol] the segment type (:year or :month), not the
    #   qualifier type
    # @return [Array<Emendate::Qualifier>]
    def segment_qualifiers(type)
      sources.when_type(type)
        .map(&:qualifiers)
        .flatten
        .reject { |qual| %i[whole beginning end].include?(qual.precision) }
    end

    def source_qualifiers
      sources.map(&:qualifiers)
        .flatten
    end

    def begin_qualifiers
      source_qualifiers.select { |qual| qual.precision == :beginning }
    end

    def end_qualifiers
      source_qualifiers.select { |qual| qual.precision == :end }
    end

    def begin_and_end_qualifiers
      begin_qualifiers + end_qualifiers
    end

    private

    # ----------------------------------------------------------------------
    # METHODS TO ADD MANIPULATED QUALIFIERS
    # ----------------------------------------------------------------------

    def add_source_segment_set_qualifiers
      sources.qualifiers.each { |qual| add_qualifier(qual) }
    end

    def add_qualifier_as_whole(qual)
      add_qualifier(Emendate::Qualifier.new(
        type: qual.type,
        precision: :whole,
        lexeme: qual.lexeme
      ))
    end

    def add_qualifier_at_precision(qual, precision)
      add_qualifier(Emendate::Qualifier.new(
        type: qual.type,
        precision: precision,
        lexeme: qual.lexeme
      ))
    end

    def segment_qualifier_processing(*pts)
      qdata = pts.map { |pt| [pt, segment_qualifiers(pt)] }
        .to_h
      process_segment_qualifiers(-1, qdata)
      process_segment_qualifiers(0, qdata)
      return if pts.length == 2

      process_segment_qualifiers(1, qdata)
    end

    def process_segment_qualifiers(part_idx, qdata)
      part = qdata.keys[part_idx]
      quals = qdata[part]
      return if quals.empty?

      quals.each { |qual| process_segment_qualifier(part, part_idx, qual) }
    end

    def process_segment_qualifier(part, part_idx, qual)
      case qual.precision
      when :single_segment
        add_qualifier_at_precision(qual, part)
      else
        pos = segment_position(part_idx)
        send(:"process_#{pos}_segment_qualifier", part, qual)
      end
    end

    def segment_position(part_idx)
      case part_idx
      when 0 then :initial
      when 1 then :mid
      when -1 then :final
      end
    end

    def process_initial_segment_qualifier(part, qual)
      case qual.precision
      when :leftward
        add_qualifier_at_precision(qual, part)
      when :rightward
        add_qualifier_as_whole(qual)
      when :single_segment
        add_qualifier_at_precision(qual, part)
      end
    end

    def process_mid_segment_qualifier(part, qual)
      case qual.precision
      when :leftward
        add_qualifier_at_precision(qual, :year_month)
      when :rightward
        add_qualifier_at_precision(qual, :month_day)
      end
    end

    def process_final_segment_qualifier(part, qual)
      case qual.precision
      when :leftward
        add_qualifier_as_whole(qual)
      when :rightward
        add_qualifier_at_precision(qual, part)
      end
    end
  end
end
