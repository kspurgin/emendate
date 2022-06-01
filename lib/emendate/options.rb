# frozen_string_literal: true

require_relative 'error'
require_relative 'options_contract'

module Emendate
  class Options
    attr_reader :options

    def initialize(opthash = {})
      return if opthash.empty?

      @opthash = opthash
      convert_dates
      handle_edtf_shortcut
      validation_errs = Emendate::OptionsContract.new.call(**opthash).errors.to_h
      validation_errs.empty? ? set_options : report_errors_and_exit(validation_errs)
    end

    def list
      Emendate.config.options.values.each{ |opt, val| puts "#{opt}: #{val}" }
    end

    def merge(opthash)
      @options = options.merge(opthash)
      verify
    end

    private

    attr_reader :opthash

    def report_errors_and_exit(errs)
      errs.each{ |key, errs| puts ":#{key} option #{errs.join('; ')}" }
      puts 'Exiting...'
      exit(1)
    end

    def map_errors(errs)
      errs.map{ |err| map_error(err) }
    end
    
    def map_error(err)
      return err if err.is_a?(String)
      
      err.map do |errval|
        binding.pry
      end
    end
    
    def set_options
      opthash.each{ |key, val| Emendate.config.options.send("#{key}=".to_sym, val) }
    end

    def handle_edtf_shortcut
      return unless opthash[:edtf]

      opthash[:beginning_hyphen] = :edtf
      opthash[:square_bracket_interpretation] = :edtf_set
    end

    def convert_dates
      dateopts = %i[open_unknown_start_date open_unknown_end_date]

      opthash.each do |key, val|
        next unless dateopts.any?(key)

        opthash[key] = convert_date(val, key)
      end
    end
    
    def convert_date(str, key)
      parts = str.split('-').map(&:to_i)
      date = Date.new(parts[0], parts[1], parts[2])
    rescue StandardError
      puts "Cannot convert #{key} value (#{str}) to date."
      unless str.is_a?(String)
        puts 'Make sure value is wrapped in single quotes if in examples CSV. Double or single quotes otherwise'
      end
      puts 'Exiting...'
      exit(1)
    else
      date
    end
  end
end
