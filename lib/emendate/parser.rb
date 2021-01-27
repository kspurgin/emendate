# frozen_string_literal: true

module Emendate
  class UnparseableValueError < StandardError; end
  
  class UnparseableTokenError < StandardError
    attr_reader :orig, :tokens, :message
    def initialize(orig:, tokens:)
      @orig = orig
      @tokens = tokens
      @message = "Unparseable value: #{orig}. The unparseable token are: #{unknown.map(&:lexeme).join('; ')}"
    end

    private
    
    def unknown
      tokens.select{ |t| t.type == :unknown }
    end
  end
  
  class Parser
    attr_reader :orig_value, :orig_tokens, :tokens, :result, :errors

    def initialize(orig:, tokens:, options: {})
      @orig_value = orig
      @orig_tokens = tokens
      @tokens = orig_tokens.clone
      @result = Emendate::Result.new(orig: orig)
      @meta = []
      @errors = []
    end

    def parse
      types = orig_tokens.map(&:type)
      return if types == [:unknown_date, :eof]
        
      raise Emendate::UnparseableTokenError.new(orig: orig, tokens: tokens) if types.include?(:unknown)

      #do_initial_certainty_check
      translate_ordinals
      standardize_formats
      convert_alphabetic_months
#      tag_date_parts
      
      #finalize
      self
    end

    private

    def standardize_formats
      standardizer = Emendate::FormatStandardizer.new(tokens: tokens)
      tokens = standardizer.standardize
    end

    def convert_alphabetic_months
      converter = Emendate::AlphaMonthConverter.new(tokens: tokens)
      tokens = converter.convert
    end

    def translate_ordinals
      translator = Emendate::OrdinalTranslator.new(tokens: tokens)
      tokens = translator.translate
    end
    
    def tag_date_parts
      tagger = Emendate::DatePartTagger.new(tokens: tokens)
      tokens = tagger.tag
    end
    
    def do_initial_certainty_check
      certain = Emendate::Certainty.new(tokens: tokens).check
      certain.values.each{ |v| result.add_certainty(v) }
      tokens = certain.tokens
    end
    
    def finalize
      raise Emendate::UnparseableValueError.new("Value: #{orig}") if result.dates.empty?
    end
  end
end
