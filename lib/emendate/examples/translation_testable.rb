# frozen_string_literal: true

require_relative '../error_util'

module Emendate
  module Examples
    # Mixin module for Examples::Tester
    module TranslationTestable
      def expected_result
        return nil unless example.testable?

        example.rows.first.send(name.to_sym)
      end

      def tested_result
        return nil unless example.testable?

        result = translate
        return 'nilValue' if result.value.nil?

        result.value
      end

      def translate
        pm = Emendate::ProcessingManager.new(example.test_string, **translate_options)
        pm.call
        result = Emendate::Translator.new(pm).translate
      rescue StandardError => err
        example.add_error(name.to_sym, Emendate::ErrorUtil.msg(err))
        nil
      else
        result
      end

      def translate_options
        translate_opt = {target_dialect: name.delete_prefix('translation_').to_sym}
        example.test_options ? instance_eval("{#{example.test_options}}").merge(translate_opt) : translate_opt
      end
    end
  end
end
