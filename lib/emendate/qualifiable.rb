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

    def year_directional_qualifiers
      source_type_qualifiers_by_precision(:year, %i[leftward rightward])
    end

    def month_directional_qualifiers
      source_type_qualifiers_by_precision(:month, %i[leftward rightward])
    end

    def season_directional_qualifiers
      source_type_qualifiers_by_precision(:season, %i[leftward rightward])
    end

    def day_directional_qualifiers
      source_type_qualifiers_by_precision(:day, %i[leftward rightward])
    end

    def source_type_qualifiers_by_precision(type, precision)
      sources.when_type(type)
        .map(&:qualifiers)
        .flatten
        .select { |qual| precision.include?(qual.precision) }
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

    def single_segment_qualifiers(segment)
      segment.qualifiers.select { |q| q.precision == :single_segment }
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

    def process_directional_qualifiers(*pts)
      qdata = pts.map { |pt| [pt, send(:"#{pt}_directional_qualifiers")] }
        .to_h
      end_directionals(pts[-1], qdata)
      begin_directionals(pts[0], qdata)
    end

    def end_directionals(part, qdata)
      quals = qdata[part]
      return if quals.empty?

      quals.each { |qual| end_directional(part, qual) }
    end

    def end_directional(part, qual)
      case qual.precision
      when :leftward
        add_qualifier_as_whole(qual)
      when :rightward
        add_qualifier_at_precision(qual, part)
      end
    end

    def begin_directionals(part, qdata)
      quals = qdata[part]
      return if quals.empty?

      quals.each { |qual| begin_directional(part, qual) }
    end

    def begin_directional(part, qual)
      case qual.precision
      when :leftward
        add_qualifier_at_precision(qual, part)
      when :rightward
        add_qualifier_as_whole(qual)
      end
    end

    def process_single_segment_qualifiers
      sources.date_parts
        .map { |dp| [dp.type, single_segment_qualifiers(dp)] }
        .each do |type, quals|
          next if quals.empty?

          quals.each { |q| add_qualifier_at_precision(q, type) }
        end
    end
  end
end
