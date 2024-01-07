# frozen_string_literal: true

require 'dry/configurable/test_interface'

module Emendate
  enable_test_interface

  module Global
    def self.included(base)
      base.before{ Emendate.config.examples.file_name = 'spec_fixture.csv' }
      # @todo Remove Emendate.reset_config from individual test files
      base.after{ Emendate.reset_config }
    end
  end
end
