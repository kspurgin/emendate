# frozen_string_literal: true

require_relative './examples'

module ExampleHelpers
  include Emendate::Examples
  extend self

  # Info about entire test set
  def example_strings
    puts all_examples.get_example_data(:examples, :test_string)
  end

  def example_fingerprints
    puts all_examples.get_example_data(:examples, :fingerprint)
  end

  def example_patterns
    puts all_examples.get_example_data(:examples, :test_pattern)
  end

  def example_tags
    puts all_examples.all_tags
  end

  def example_data_set_tags
    puts all_examples.tags('data_set')
  end

  def example_date_type_tags
    puts all_examples.tags('date_type')
  end

  # Creating example sets

  # The entire set
  def all_examples
    ExampleSet.new
  end

  # Filtered by tag(s)
  def examples_with(data_set: '', date_type: '')
    ExampleSet.new(data_sets: data_set, date_types: date_type)
  end

  # With one example (by string/options)
  def specific_example(str, opt)
    rows = Emendate::Examples::Csv.rows(str, opt)
      .sort_by{ |row| row.dateval_occurrence }
    if rows.empty?
      puts "No matching rows"
      exit
    end
    
    Emendate::Examples::ExampleSet.new(rows: rows)
  end


  def tokenize_examples(examples = ExampleSet.new)
    ex = examples.strings
    lexed = ex.map{ |str| Emendate.lex(str) }
    tokens = lexed.map{ |t| t.tokens.types }
    ex.zip(tokens)
  end

  def parse_examples(examples: ExampleSet.new, stage: nil, options: {})
    ex = examples.strings
    if stage.nil?
      ex.map{ |str| Emendate.process(str, options) }
    else
      ex.map{ |str| Emendate.prep_for(str, stage, options) }
    end
  end

  # stage should be a SegmentSet-holding instance variable of ProcessingManager
  def parsed_example_tokens(examples: ExampleSet.new, token_types: :all, stage: nil, options: {})
    parsed = parse_examples(examples: examples, stage: stage, options: options).reject{ |pm| pm.state == :failed }
    processed = parsed.map(&:tokens)
    tokens = token_types == :date ? processed.map(&:date_part_types) : processed.map(&:types)
    ex = parsed.map{ |pm| pm.orig_string }
    ex.zip(tokens)
  end

  def failed_to_parse(examples: ExampleSet.new)
    parse_examples(examples: examples)
      .select{ |pm| pm.state == :failed }
      .map{ |f| "#{f.orig_string} - #{f.errors.join('; ')}" }
  end

  # def example_tokens_by_str
  #   results = tokenize_examples.sort
  #   results.each{ |str, tokens| puts "#{str.ljust(example_length)}\t#{tokens.inspect}" }
  # end

  # def example_tokens_by_token
  #   results = tokenize_examples.sort_by{ |ex| ex[1] }
  #   results.each{ |str, tokens| puts "#{tokens.join(' ')}  -- String: #{str}" }
  # end

  # def parsed_tokens_by_token(data_set: '', stage: :final)
  #   results = parsed_example_tokens(data_set: data_set, stage: stage, date_type: date_type).sort_by{ |ex| ex[1] }
  #   results.each{ |str, tokens| puts "#{tokens.join(' ')}  -- String: #{str}" }
  # end

  # stage should be a SegmentSet-holding instance variable of ProcessingManager
  def unique_type_patterns(examples: ExampleSet.new, stage: nil, options: {} )
    results = parsed_example_tokens(examples: examples, stage: stage, options: options)
    patterns = results.map{ |parsed| parsed[1] }.uniq.sort.map{ |pattern| [pattern, []] }.to_h
    results.each{ |r| patterns[r[1]] << r[0] }
    patterns.keys.sort.each do |pattern|
      puts pattern.join(' ')
      patterns[pattern].each{ |e| puts '     ' + e }
    end

    failed = failed_to_parse(examples: examples)
    return if failed.empty?
    
    puts "\n\n PARSING FAILURES"
    puts failed
  end

  def example_results(date_type: '', options: {} )
    parse_examples(tag: tag, options: options).map(&:result)
  end

  def example_length
    EXAMPLES.keys.sort_by{ |k| k.length }[-1].length
  end
end
