# frozen_string_literal: true

require "forwardable"
require "json"

require_relative "qualifiable"

module Emendate
  # Wrapper around a DateType segment, used as part of Result
  #
  # @todo Implement index dates (see timetwister)
  class ParsedDate
    include Emendate::Qualifiable
    extend Forwardable

    # @return [String]
    attr_reader :original_string
    attr_reader :date_start
    attr_reader :date_end
    attr_reader :date_start_full
    attr_reader :date_end_full
    # @return [Boolean]
    attr_reader :inclusive_range
    # @return [Array<Emendate::Qualifier>]
    attr_reader :qualifiers
    # @return [String]
    attr_reader :date_type
    # @return [Emendate::DateTypes::DateType]
    attr_reader :source

    def_delegators :@source, :sources, :type,
      :lexeme, :orig_string,
      :earliest, :earliest_at_granularity,
      :latest, :latest_at_granularity,
      :range_switch, :era, :qualifiers

    # @param date [Emendate::DateTypes::DateType]
    # @param orig [String]
    # @param qualifiers [Array<Emendate::Qualifier>]
    def initialize(date:, orig:, qualifiers: [])
      raise(NonDateTypeError) unless date.date_type?

      @original_string = get_original_string(date, orig)
      @date_start = nil
      @date_end = nil
      @date_start_full = date.earliest&.iso8601
      @date_end_full = date.latest&.iso8601
      @inclusive_range = date.range?
      @qualifiers = (qualifiers + date.qualifiers).flatten.uniq
      @date_type = date.class.name.split("::")[-1]
      @source = date
    end

    def to_h
      hashable_variables.map do |var|
        varsym = var.to_s.sub("@", "").to_sym
        [varsym, instance_variable_get(var)]
      end.to_h
        .merge({
          range_switch: range_switch,
          era: era
        })
    end

    def to_json
      to_h.to_json
    end

    # @!macro set_type_attr
    def set_type
      source.set_type
    rescue
      nil
    end

    private

    def hashable_variables
      instance_variables - %i[@date_type @source]
    end

    def get_original_string(datetype, orig)
      if datetype.respond_to?(:lexeme)
        datetype.lexeme
      else
        orig
      end
    end
  end
end
