# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in emendate.gemspec
gemspec

group :documentation do
  gem 'asciidoctor'
  gem 'redcarpet', '~>3.5' # markdown parser for generating documentation
  gem 'yard'
end

group :test do
  gem 'rspec'
  gem 'simplecov', '~> 0.21', require: false
end

group :development do
  gem 'debug', '>= 1.0.0'
  gem 'pry', '~> 0.14.1'
  gem 'rake', '~> 12.0'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rspec', require: false
end
