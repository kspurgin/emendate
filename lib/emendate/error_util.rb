# frozen_string_literal: true

module Emendate
  # shared functions for dealing with errors
  module ErrorUtil
    module_function

    def msg(err)
      [err.message, err.backtrace.first(5)].flatten
    end
  end
end
