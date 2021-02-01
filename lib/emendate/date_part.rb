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
      @source_tokens = Emendate::MixedSet.new
      return if opts[:source_tokens].nil?
      return if opts[:source_tokens].empty?
      opts[:source_tokens].each{ |t| source_tokens << t }
    end
  end
end
