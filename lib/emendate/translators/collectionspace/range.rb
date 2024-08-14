# frozen_string_literal: true

require_relative "../abstract"

module Emendate
  module Translators
    module Collectionspace
      class Range < Emendate::Translators::Abstract
        private

        attr_reader :base

        def translate_value
          @base = computed
          qualify
        end

        private

        def qualify_qualifiers
          return if pdate.certain?

          vals = qual_hash(pdate)
          vals.reject! { |key, val| val.empty? }

          if vals.key?(:start)
            @qualified = @qualified.merge({
              dateEarliestSingleCertainty: vals[:start]
            })
          end
          if vals.key?(:end)
            @qualified = @qualified.merge({dateLatestCertainty: vals[:end]})
          end
        end

        def qual_hash(pdate)
          h = {
            start: [],
            end: []
          }
          pdate.qualifiers.dup.each do |qual|
            precision = qual.precision
            if precision == :whole
              term = qualifier_term(qual)
              %i[start end].each { |prec| h[prec] << term }
            else
              h[qual.precision] << qualifier_term(qual)
            end
          end
          h.transform_values do |arr|
            arr.compact.uniq.sort.join(", ").capitalize
          end
        end
      end
    end
  end
end
