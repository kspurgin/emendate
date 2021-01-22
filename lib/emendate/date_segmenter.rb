# frozen_string_literal: true

module Emendate

  class DateSegment
    attr_reader :tokens, :type, :parts
    def initialize(tokens:, type: :unknown_specificity)
      @tokens = tokens
      @type = type
      @parts = []
    end
  end
  
  class DateSegmenter
    attr_reader :orig, :tokens
    attr_accessor :next_t, :start_t

    DATESEP = [:hyphen, :slash].freeze
    
    def initialize(tokens:)
      @orig = tokens
      @tokens = []
      @next_t = 0
      @start_t = 0
    end

    def segmentation
      while pending_tokens?
        consume

        dateseg = recursive_parse
      end
    end

    private

    def consume(offset = 1)
      t = lookahead(offset)
      self.next_t += offset
      t
    end

    def lookahead(offset = 1)
      lookahead_t = (next_t - 1) + offset
      return nil if lookahead_t < 0 || lookahead_t >= orig.length

      orig[lookahead_t]
    end

    def previous
      lookahead(-1)
    end

    def current
      lookahead(0)
    end

    def nxt
      lookahead
    end
    
    def pending_tokens?
      next_t < orig.length
    end

    def parse_year
      return Emendate::DateSegment.new(tokens: [current], type: :year) if nxt_terminator?
      token_holder = []
      token_holder << current
      consume if nxt_sep?
      consume
      next_function = determine_post_year_parsing_function
    end

    def parse_yyyymm
    end

    def parse_compressed_iso8601
    end

    def passthrough
      tokens << current
    end

    def determine_post_year_parsing_function
      if current.type == :number1or2 && Emendate::NumberUtils.valid_month?(current.lexeme)
        :parse_year_month
      elsif current.type == :number1or2 && Emendate::NumberUtils.valid_season?(current.lexeme)
        :parse_year_season
      end
    end
    
    def determine_parsing_function
      if [:number4, :number3].include?(current.type) && Emendate::NumberUtils.valid_year?(current.lexeme)
        :parse_year
      elsif current.type == :number6
        :parse_yyyymm
      elsif current.type == :number8
        :parse_compressed_iso8601
      else
        :passthrough
      end
    end

    def nxt_sep?
      DATESEP.include?(nxt.type)
    end
    
    def nxt_terminator?
      nxt.type == :eof
    end

    def nxt_not_terminator?
      nxt.type != :eof
    end
    
    def recursive_parse
      parsing_function = determine_parsing_function
      if parsing_function.nil?
        #unrecognized_token_error
        return
      end

      expr = send(parsing_function)
      return if expr.nil?

      expr
    end
  end
end
