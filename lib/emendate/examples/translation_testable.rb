# frozen_string_literal: true

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
        return result if result.nil?

        result.value
      end

      def translate
        pm = Emendate::ProcessingManager.new(example.test_string, **translate_options)
        pm.process
        result = Emendate::Translator.new(pm).translate
      rescue StandardError => err
        err_msg = [err.message, err.backtrace.first(3)].flatten
        example.add_error(name.to_sym, err_msg)
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
