# frozen_string_literal: true

require_relative './examples'

module Helpers
  include Examples
  extend self

  def example_strings
    Examples.new.unique_example_strings
  end

  def example_tags
    EXAMPLES.map{ |str, exhash| [str, exhash[:results]] }
      .to_h
      .map{ |str, arr| [str, arr.map{ |result| result[:tags] }.flatten.uniq] }
      .to_h
  end

  
  def run_sequential_examples(options = {})
    EXAMPLES.keys.each do |str|
      begin
        processed = Emendate.process(str, options)
      rescue StandardError => e
        puts "#{str} - ERROR: #{e.message}"
      else
        if processed.state == :failed
          puts "#{str} - Failure state"
          next
        end
      end
    end
  end
  

  def examples_with_tag(tag)
    example_tags.keep_if{ |str, tags| tags.include?(tag) }.keys
  end

  def tokenize_examples
    ex = EXAMPLES.keys
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
