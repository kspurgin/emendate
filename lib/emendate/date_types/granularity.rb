# frozen_string_literal: true

module Emendate
  module DateTypes
    # mixin module to add granularity lookup
    #
    # NOTHING FROM THIS IS IMPLEMENTED ANYWHERE YET
    module Granularity
      extend self

      Registry = {
        century: :year,
        decade: :year,
        millennium: :year,
        openrangedate: :dependent,
        range: :dependent,
        unprocessable: :no_granularity,
        untokenizable: :no_granularity,
        year: :year,
        yearmonth: :month,
        yearmonthday: :day,
        yearseason: :month
      }

      def granularity
        datetype = type.to_s.delete_suffix("_date_type").to_sym
        Registry[datetype]
      end

      def granular_date(side:, date_type:)
      end
    end
  end
end
