# frozen_string_literal: true

require 'emendate'

module Helpers
  module_function


  def test_rows(str, opt)
    Emendate.config.examples.file_name = 'spec_fixture.csv'
    Emendate::Examples::Csv.rows(str, opt)
      .sort_by{ |row| row.dateval_occurrence }
  end
end

