# frozen_string_literal: true

module Emendate
  class StringNormalizer
    include Dry::Monads[:result]

    class << self
      def call(...)
        self.new(...).call
      end
    end

    def initialize(tokens)
      if tokens.is_a?(String)
        @orig = tokens
      else
        @orig = tokens.orig_string
      end
    end

    def call
      result = orig.downcase.sub('[?]', '?')
        .sub('(?)', '?')
        .sub(/^c([^a-z])/, 'circa\1') # initial c followed by non-letter
        .gsub(/b\.?c\.?(e\.?|)/, 'bce') # cleanup bc, bce
        .gsub(/(a\.?d\.?|c\.?e\.?)/, 'ce') # cleanup ad, ce
        .gsub(/b\.?p\.?/, 'bp') # cleanup bp
        .sub(/^n\.? ?d\.?$/, 'nodate') # cleanup nd
        .sub(/^ *not dated *$/, 'notdated') # cleanup not dated
        .sub(/^ *unkn?\.? *$/, 'unk') # cleanup unk.
        .sub(/^ *date unknown?\.? *$/, 'dateunknown')
        .sub(/^ *unknown date?\.? *$/, 'unknowndate')
        .sub(/(st|nd|rd|th) c\.?$/, '\1 century') # ending c after ordinal
    rescue StandardError => err
      Failure(err)
    else
      t = Emendate::SegmentSets::TokenSet.new(
        string: orig,
        norm: result
      )
      Success(t)
    end

    private

    attr_reader :orig
  end
end
