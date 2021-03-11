# frozen_string_literal: true

module Emendate
  # Methods used by processing step Objects to edit the result they return
  # This is not the final result
  # Classes including this module must have a `result` attr_reader
  module ResultEditable
    def replace_x_with_new(x:, new:)
      ins_pt = result.find_index(x) + 1
      result.insert(ins_pt, new)
      result.delete(x)
    end
  end
end
