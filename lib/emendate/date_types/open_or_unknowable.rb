# frozen_string_literal: true

module Emendate
  module DateTypes
    module OpenOrUnknowable
      def initialize(**opts)
        super
        @usage = opts[:usage]
        @use_date = Emendate.options.send(setting)
      end

      def earliest
        use_date if usage == :start
      end

      def latest
        use_date if usage == :end
      end

      # the *_at_granularity values should depend upon the granularity of the start/end date this is paired with
      def earliest_at_granularity
        earliest
      end

      def latest_at_granularity
        latest
      end

      def literal
        use_date.strftime('%Y%m%d').to_i
      end

      def range?
        false
      end

      def year
        literal.to_s[0..3]
      end

      private

      def setting
        "open_unknown_#{usage}_date".to_sym
      end
    end
  end
end
