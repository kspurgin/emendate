# frozen_string_literal: true

require 'emendate/segment'

module Emendate
  class DatePart < Emendate::Segment
    extend Forwardable

    attr_reader :source_tokens

    # allows any subclass of SementSet to return a list of segments representing date parts
    def date_part?
      true
    end
    
    private
    
    def post_initialize(opts)
      @source_token = opts[:source_tokens] || default_source_tokens
    end


    def default_source_tokens
      Emendate::TokenSet.new
    end
  end
end
