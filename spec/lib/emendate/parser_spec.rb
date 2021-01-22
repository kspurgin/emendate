require 'spec_helper'

RSpec.describe Emendate::Parser do
  describe '#parse' do
    context 'unknown dates' do
      it 'result with no parsed dates' do
        ex = Helpers::EXAMPLES.select do |ex, arr|
          arr.select{ |h| h[:tags].include?(:indicates_no_date) }.length > 0
        end
        lex = ex.keys.map{ |str| Emendate::Lexer.new(str) }.each{ |l| l.start_tokenization}
        parse = lex.map{ |l| Emendate::Parser.new(orig: l.orig, tokens: l.tokens)}.each{ |p| p.parse }
        results = parse.map{ |p| p.result.dates }.uniq.flatten
        expect(results).to eq([])
      end
    end

    context 'unparseable dates' do
      xit 'raises error' do
        ex = Helpers::EXAMPLES.select do |ex, arr|
          arr.select{ |h| h[:tags].include?(:unparseable) }.length > 0
        end
        lex = ex.keys.map{ |str| Emendate::Lexer.new(str) }.each{ |l| l.start_tokenization}
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
      lex = Emendate::Lexer.new('2020-Jan-31')
      lex.start_tokenization
      parser = Emendate::Parser.new(orig: lex.orig, tokens: lex.tokens)
      parsed = parser.parse
      binding.pry
    end
  end
end
