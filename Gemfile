# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in emendate.gemspec
gemspec

gem 'rake', '~> 12.0'
gem 'rspec', '~> 3.0'

group :test do
  gem 'simplecov', require: false
end

group :test, :development do
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rspec', require: false
  gem 'ruby_jard'
end
