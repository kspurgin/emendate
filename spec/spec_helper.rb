# frozen_string_literal: true

require 'bundler/setup'
#require 'simplecov'
#SimpleCov.start

require 'dry/configurable/test_interface'

require_relative './helpers'
require 'emendate'

module Emendate
  enable_test_interface
end

require 'pry'

RSpec.configure do |config|
  config.include Helpers

  config.define_derived_metadata do |meta|
    meta[:aggregate_failures] = true
  end
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
