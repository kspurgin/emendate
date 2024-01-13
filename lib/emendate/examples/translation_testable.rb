# frozen_string_literal: true

require_relative "../error_util"

module Emendate
  module Examples
    # Mixin module for Examples::Tester
    module TranslationTestable
      def expected_result
        return nil unless example.testable?

        example.rows.map { |row| row.send(name.to_sym) }
      end

      def tested_result
        return nil unless example.testable?

        result = translate
        return "nilValue" if result.values.nil?

        result.values
      end

      def translate
        pm = Emendate::ProcessingManager.new(
          example.test_string,
          **translate_options
        )
        pm.call
        result = Emendate::Translator.call(pm)
      rescue => err
        example.add_error(name.to_sym, Emendate::ErrorUtil.msg(err))
        nil
      else
        result
      end

      def translate_options
        translate_opt = {dialect: name.delete_prefix("translation_").to_sym}
        if example.test_options
          instance_eval("{#{example.test_options}}", __FILE__,
            __LINE__ - 1).merge(translate_opt)
        else
          translate_opt
        end
      end
    end
  end
end
