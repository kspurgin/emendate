# frozen_string_literal: true

module Emendate
  # Appropriately tags :letter_c segments, which may be interpreted as
  #   circa, copyright, or century
  #
  # Lexer tags a single :letter_c at the beginning of a string as
  #   :approximate or :copyright, according to the :c_before_date
  #   option. Initial :copyright has been collapsed by TokenCollapser
  #   and initial :approximate has been handled by UnstructuredCertaintyHandler.
  #
  # FormatStandardizer handles tagging the c in `number1or2 letter_c` as
  #   :century, because that class needs to standardize numerous patterns
  #   involving century values.
  #
  # This class only needs to deal with other :letter_c segments
  #   occurring elsewhere in the string.
  class LetterCTagger
    include Dry::Monads[:result]

    class << self
      def call(...)
        new(...).call
      end
    end

    def initialize(tokens)
      @result = Emendate::SegmentSet.new.copy(tokens)
      @c_handling = Emendate.config.options.c_before_date
    end

    def call
      while taggable?
        tagger = get_tagger
        break unless tagger

        pre = result.types.dup
        tagger.call
        break if result.types == pre
      end
      Success(result)
    end

    private

    attr_reader :result, :c_handling

    def taggable? = result.types.include?(:letter_c)

    def get_tagger
      if result.first.type == :letter_c
        proc { handle_initial_letter_c }
      elsif result.type_string.match?(/.*letter_c number.*/)
        proc { collapse_into_number }
      elsif result.type_string.match?(/.*range_indicator letter_c.*/)
        proc { handle_after_range_indicator }
      end
    end

    def handle_initial_letter_c
      case c_handling
      when :circa
        treat_as_circa(result[0], result[1])
      when :copyright
        treat_as_copyright(result[0], result[1])
      end
    end

    def collapse_into_number
      result.when_type(:letter_c).each do |cseg|
        nseg = result.next_segment(cseg)
        next unless nseg.number?

        case c_handling
        when :circa then treat_as_circa(cseg, nseg)
        when :copyright then treat_as_copyright(cseg, nseg)
        end
      end
    end

    def handle_after_range_indicator
      _ri, c = result.extract(%i[range_indicator letter_c]).segments
      case c_handling
      when :circa then treat_as_circa(c, result.next_segment(c))
      when :copyright then treat_as_copyright(c, result.next_segment(c))
      end
    end

    def treat_as_circa(s1, s2, direction = :forward)
      target = (direction == :forward) ? s2 : s1
      target.add_qualifier(
        Qualifier.new(type: :approximate, precision: :beginning,
          lexeme: "circa")
      )
      result.collapse_token_pair(s1, s2, direction)
    end

    def treat_as_copyright(s1, s2, direction = :forward)
      result.collapse_token_pair(s1, s2, direction)
    end
  end
end
