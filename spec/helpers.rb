# frozen_string_literal: true

require_relative './examples'

module Helpers
  include Examples
  extend self

  def example_strings
    ExampleSet.new.tests.map(&:string).uniq.sort
  end

  def example_patterns
    ExampleSet.new.tests.map(&:pattern).uniq.sort
  end

  def example_tags
    e = ExampleSet.new
    tags = e.data_sets + e.date_types
    tags.uniq.sort
  end

  def example_data_set_tags
    ExampleSet.new.data_sets
  end

  def example_date_type_tags
    ExampleSet.new.date_types
  end
  
  def run_sequential_examples(examples: ExampleSet.new, tests: nil, fail_fast: true)
    examples.run_tests(test_list: tests, fail_fast: fail_fast)
    examples.group_by_pass_fail[:failures].each{ |test| puts test.full_report }
    examples.pass_fail_summary
  end
  

  def examples_with(data_set: '', date_type: '')
    ExampleSet.new(data_set: data_set, date_type: date_type)
  end

  def tokenize_examples(examples = ExampleSet.new)
    ex = examples.strings
    lexed = ex.map{ |str| Emendate.lex(str) }
    tokens = lexed.map{ |t| t.tokens.types }
    ex.zip(tokens)
  end

  def parse_examples(tag: nil, stage: nil, options: {})
    ex = tag.nil? ? EXAMPLES.keys : examples_with_tag(tag)
    # for regular use
    if stage.nil?
      ex.map{ |str| Emendate.process(str, options) }
    else
      ex.map{ |str| Emendate.prep_for(str, stage, options) }
    end
  end

  # stage should be a SegmentSet-holding instance variable of ProcessingManager
  def parsed_example_tokens(type: :all, stage: nil, tag: nil, options: {})
    parsed = parse_examples(tag: tag, stage: stage, options: options).reject{ |pm| pm.state == :failed }
    processed = parsed.map(&:tokens)
    tokens = type == :date ? processed.map(&:date_part_types) : processed.map(&:types)
    ex = parsed.map{ |pm| pm.orig_string }
    ex.zip(tokens)
  end

  def failed_to_parse(tag: nil)
    parsed = parse_examples(tag: tag).select{ |pm| pm.state == :failed }
    parsed.map{ |f| "#{f.orig_string} - #{f.errors.join('; ')}" }
  end

  def example_tokens_by_str
    results = tokenize_examples.sort
    results.each{ |str, tokens| puts "#{str.ljust(example_length)}\t#{tokens.inspect}" }
  end

  def example_tokens_by_token
    results = tokenize_examples.sort_by{ |ex| ex[1] }
    results.each{ |str, tokens| puts "#{tokens.join(' ')}  -- String: #{str}" }
  end

  def parsed_tokens_by_token(type: :all, stage: :final)
    results = parsed_example_tokens(type: type, stage: stage).sort_by{ |ex| ex[1] }
    results.each{ |str, tokens| puts "#{tokens.join(' ')}  -- String: #{str}" }
  end

  # stage should be a SegmentSet-holding instance variable of ProcessingManager
  def unique_type_patterns(type: :all, stage: nil, tag: nil, options: {} )
    results = parsed_example_tokens(type: type, stage: stage, tag: tag, options: options)
    patterns = results.map{ |parsed| parsed[1] }.uniq.sort.map{ |pattern| [pattern, []] }.to_h
    results.each{ |r| patterns[r[1]] << r[0] }
    patterns.keys.sort.each do |pattern|
      puts pattern.join(' ')
      patterns[pattern].each{ |e| puts '     ' + e }
    end

    puts "\n\n PARSING FAILURES"
    puts failed_to_parse(tag: tag)
  end

  def example_results(tag: nil, options: {} )
    parse_examples(tag: tag, options: options).map(&:result)
  end

  def example_length
    EXAMPLES.keys.sort_by{ |k| k.length }[-1].length
  end
end
