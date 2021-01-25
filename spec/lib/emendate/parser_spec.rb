require 'spec_helper'

RSpec.describe Emendate::Parser do
  describe '#parse' do
    context 'unknown dates' do
      it 'result with no parsed dates' do
        ex = Helpers::EXAMPLES.select do |ex, arr|
          arr.select{ |h| h[:tags].include?(:indicates_no_date) }.length > 0
        end
        parsed = ex.keys.map{ |str| Emendate.parse(str) }
        results = parsed.map{ |p| p.result.dates }.uniq.flatten
        expect(results).to eq([])
      end
    end

    context 'unparseable dates' do
      xit 'raises error' do
        ex = Helpers::EXAMPLES.select do |ex, arr|
          arr.select{ |h| h[:tags].include?(:unparseable) }.length > 0
        end
        lex = ex.keys.map{ |str| Emendate.lex(str) }
        results = []
        parse = lex.map{ |l| Emendate::Parser.new(orig: l.orig, tokens: l.tokens)}.each do |parser|
          begin
            parser.parse
          rescue Emendate::UnparseableTokenError => e
            results << e.message
          rescue Emendate::UnparseableValueError => e
            results << e.message
          end
        end
        expect(results.length).to eq(2)
      end
    end

    it 'does test' do
      parsed = Emendate.parse('2020-Jan-31')
#      binding.pry
    end
  end
end
