# frozen_string_literal: true

module Emendate
  class Result

    attr_reader :orig, :dates, :certainty

    def initialize(orig:)
      @orig = orig
      @dates = []
      @certainty = []
    end

    def add_certainty(value)
      certainty << value
    end
    
  end
end
