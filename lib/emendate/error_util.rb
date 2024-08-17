# frozen_string_literal: true

module Emendate
  # shared functions for dealing with errors
  module ErrorUtil
    module_function

    def msg(err)
      if err.is_a?(Exception)
        [err.message, err.backtrace.first(5)].flatten
      elsif err.is_a?(Emendate::DateTypes::Error)
        [err.error_type.to_s.capitalize, err.message]
      end
    end
  end
end
