# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in emendate.gemspec
gemspec

gem 'rake', '~> 12.0'
gem 'rspec', '~> 3.0'

group :test do
  gem 'simplecov', '~> 0.21', require: false
end

group :test, :development do
  gem 'pry', '~> 0.14.1'
  gem 'pry-byebug', '~> 3.8'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rspec', require: false
end


