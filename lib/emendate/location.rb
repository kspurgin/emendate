# frozen_string_literal: true

module Emendate
  Location = Struct.new(:col, :length) do
    def ==(other)
      col == other.col &&
        length == other.length
    end
  end
end
