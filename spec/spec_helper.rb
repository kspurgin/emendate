# frozen_string_literal: true

require 'bundler/setup'
#require 'simplecov'
#SimpleCov.start

require_relative './helpers'
require_relative './support/shared_contexts/global'

require 'emendate'

module Emendate
  enable_test_interface
end

require 'pry'

RSpec.configure do |config|
#  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.include Emendate::Global
  config.include Helpers

  config.define_derived_metadata do |meta|
    meta[:aggregate_failures] = true
  end
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.order = :random
  Kernel.srand config.seed
  
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
