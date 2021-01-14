module Emendate
  class Lexer
    SPACE = ' '.freeze
    HYPHEN = ["\u002D", "\u2010", "\u2011", "\u2012", "\u2013", "\u2014", "\u2015", "\u2043"].freeze
    SLASH = '/'.freeze

    attr_reader :orig, :tokens
    attr_accessor :next_p, :lexeme_start_p
    def initialize(orig)
      @orig = orig
      @tokens = []
      @next_p = 0
      @lexeme_start_p = 0
    end

    def start_tokenization
      while orig_uncompleted?
        tokenize
      end

      tokens << Token.new(type: :eof, lexeme: '', location: after_source_end_location)
    end

    private

    def tokenize
      self.lexeme_start_p = next_p
      token = nil

      c = consume

      return if c == SPACE
      token =
        if HYPHEN.include?(c)
          token_of_type(c, :hyphen)
        elsif c == SLASH
          token_of_type(c, :slash)
        end

      token = Token.new(lexeme: c, type: :unknown, location: current_location) if token.nil?
      
      tokens << token
    end

    def token_of_type(lexeme, type)
      Token.new(lexeme: lexeme, type: type, location: current_location)
    end
    
    def consume
      c = lookahead
      self.next_p += 1
      c
    end

    def lookahead(offset = 1)
      lookahead_p = (next_p - 1) + offset
      return "\0" if lookahead_p >= orig.length

      orig[lookahead_p]
    end

    
    def orig_completed?
      next_p >= orig.length # our pointer starts at 0, so the last char is length - 1.
    end

    def orig_uncompleted?
      !orig_completed?
    end

    def current_location
      Location.new(lexeme_start_p, next_p - lexeme_start_p)
    end

    def after_source_end_location
      Location.new(next_p, 1)
    end

  end
end
