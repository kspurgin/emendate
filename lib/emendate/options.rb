# frozen_string_literal: true

require_relative 'error'
require_relative 'options_contract'

module Emendate
  # To add or update an option there are several places to edit:
  # - #defaults in this file -- used to reset to defaults without restarting application
  # - Emendate::OptionsContract -- used to validate configs
  # - Emendate (lib/emendate.rb) -- register the options with dry-configurable
  # - docs/options.adoc
  class Options
    attr_reader :options

    def initialize(opthash = {})
      if opthash.empty?
        set_options(defaults)
        return
      end

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

    def defaults
      {:edtf => false,
       :ambiguous_month_day => :as_month_day,
       :ambiguous_month_day_year => :as_month_day,
       :ambiguous_month_year => :as_year,
       :before_date_treatment => :point,
       :two_digit_year_handling => :coerce,
       :ambiguous_year_rollback_threshold => Date.today.year.to_s[-2..-1].to_i,
       :square_bracket_interpretation => :inferred_date,
       :pluralized_date_interpretation => :decade,
       :open_unknown_start_date => Date.new(1583, 1, 1),
       :open_unknown_end_date => Date.new(2999, 12, 31),
       :beginning_hyphen => :unknown,
       :ending_hyphen => :open,
       :unknown_date_output => :orig,
       :unknown_date_output_string => "",
       :target_dialect => nil,
       :max_output_dates => :all}
    end
    
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
    
    def set_options(opts = opthash)
      opts.each{ |key, val| Emendate.config.options.send("#{key}=".to_sym, val) }
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
