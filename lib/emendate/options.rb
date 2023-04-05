# frozen_string_literal: true

require_relative 'options_contract'

module Emendate
  # To add or update an option there are several places to edit:
  # - #defaults in this file -- used to reset to defaults without restarting application
  # - Emendate::OptionsContract -- used to validate configs
  # - Emendate (lib/emendate.rb) -- register the options with dry-configurable
  # - docs/options.adoc
  class Options
    attr_reader :options

    def self.list
      Emendate.config.options.values.each{ |opt, val| puts "#{opt}: #{val}" }
    end

    def initialize(opthash = {})
      return if opthash.empty?

      @opthash = opthash
      validation_errs = Emendate::OptionsContract.new.call(**opthash).errors.to_h
      if validation_errs.empty?
        set_options
        handle_edtf_shortcut if Emendate.options.edtf
        handle_collectionspace if Emendate.options.dialect == :collectionspace
      else
        report_errors_and_exit(validation_errs)
      end
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
        fail StandardError, 'not implemented'
      end
    end

    def set_options(opts = opthash)
      opts.each{ |key, val| Emendate.config.options.send("#{key}=".to_sym, val) }
    end

    def handle_collectionspace
      cs_opts = {
        and_or_date_handling: :single_range,
        bce_handling: :naive,
        before_date_treatment: :range
      }
      set_options(cs_opts)
    end

    def handle_edtf_shortcut
      edtf_opts = {
        beginning_hyphen: :edtf,
        ending_slash: :unknown,
        square_bracket_interpretation: :edtf_set,
        max_month_number_handling: :edtf_level_2
      }
      set_options(edtf_opts)
    end
  end
end
