# frozen_string_literal: true

module Emendate
  module DateTypes
    
    class DateType
      attr_reader :year, :pre, :post, :type
      attr_accessor :parts
      def initialize(**opts)
        @year = opts[:year].is_a?(Integer) ? opts[:year] : opts[:year].to_i
        @pre = Emendate::TokenSet.new
        @post = Emendate::TokenSet.new
        @parts = Emendate::TokenSet.new
        opts[:children].each{ |t| parts << t } unless opts[:children].nil?
      end
      
      def earliest
        raise NotImplementedError
      end

      def latest
        raise NotImplementedError
      end

      def lexeme
        raise NotImplementedError
      end

      def type
        "#{self.class.name.split('::').last.downcase}_date_type".to_sym
      end
    end
  end
end
