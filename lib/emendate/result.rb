# frozen_string_literal: true

module Emendate
  class Result

    attr_reader :original_string, :errors, :warnings, :dates

    def initialize(resulthash)
      @original_string = resulthash[:original_string]
      @errors = resulthash[:errors]
      @warnings = resulthash[:warnings]
      @dates = resulthash[:result]
    end    
  end
end
