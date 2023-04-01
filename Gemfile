# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in emendate.gemspec
gemspec

group :documentation do
  gem 'redcarpet', '~>3.5' # markdown parser for generating documentation
  gem 'yard', '~>0.9.28'
end

group :test do
  gem 'rspec', '~> 3.0'
  gem 'simplecov', '~> 0.21', require: false
end

group :development do
  gem 'pry', '~> 0.14.1'
  gem 'pry-byebug', '~> 3.8'
  gem 'rake', '~> 12.0'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rspec', require: false
end
