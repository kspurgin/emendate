# frozen_string_literal: true

module Emendate
  module Examples
    # Mixin module to set up instance variables for the tag types
    module Taggable
      def set_up_tags(data_sets, date_types)
        @data_sets = data_sets.split(";")
        @date_types = date_types.split(";")
        %i[data_sets date_types].each do |tag|
          self.class.define_method(tag) do
            instance_variable_get(:"@#{tag}")
          end
        end
      end

      def tags_to_s
        "(data_sets: #{data_sets.join(";")}, date_types: #{date_types.join(";")})"
      end
    end
  end
end
