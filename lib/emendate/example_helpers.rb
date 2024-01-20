# frozen_string_literal: true

require_relative "examples"

module ExampleHelpers
  include Emendate::Examples
  extend self

  # @!group Getting info about entire test set

  # @return [Array<String>]
  def example_strings
    all_examples.get_example_data(data_method: :test_string)
  end

  # @return [Array<String>]
  def example_fingerprints
    all_examples.get_example_data(data_method: :fingerprint)
  end

  # @return [Array<String>]
  def example_patterns
    all_examples.get_example_data(data_method: :test_pattern)
  end

  # @return [Array<String>] tag and indication of tag category
  def example_tags = all_examples.all_tags

  # @return [Array<String>]
  def example_data_set_tags
    all_examples.tags("data_set")
      .map { |tag| tag.delete_suffix(" (tags_data_set)") }
  end

  # @return [Array<String>]
  def example_date_type_tags
    all_examples.tags("date_type")
      .map { |tag| tag.delete_suffix(" (tags_date_type)") }
  end

  # @!endgroup

  # @!group Creating/selecting example sets

  # Convenience wrapper for ExampleSet.new
  # @return [Emendate::Examples::ExampleSet] entire example set
  def all_examples
    ExampleSet.new
  end

  # @param data_set [String] one or more data set tags, separated by
  #   semicolon (no spaces)
  # @param date_type [String] one or more date type tags, separated by
  #   semicolon (no spaces)
  # @return [Emendate::Examples::ExampleSet] examples matching specified tags
  # @note All tags are Boolean AND-ed. That is, only examples having ALL the
  #   specified tags will be included in the example set
  # @example Approximate year dates in ba data set
  #   Emendate.examples_with(
  #     data_set: "ba", date_type: "approximate;year_granularity"
  #   )
  def examples_with(data_set: "", date_type: "")
    ExampleSet.new(data_sets: data_set, date_types: date_type)
  end

  # @param str [String] matching test_string value from examples CSV
  # @param opt [String] matching entire contents of test_options column in
  #   examples CSV
  # @return [Emendate::Examples::ExampleSet] examples matching specified tags
  def specific_example(str, opt)
    rows = Emendate::Examples::Csv.rows(str, opt)
      .sort_by { |row| row.dateval_occurrence }
    if rows.empty?
      puts "No matching rows"
      exit
    end

    Emendate::Examples::ExampleSet.new(rows: rows)
  end

  # @!endgroup

  # @!group Processing/parsing examples in a set

  # @param examples [Emendate::Examples::ExampleSet]
  # @return [Hash{String=>Array<Symbol>}]
  def tokenize_examples(examples = ExampleSet.new)
    ex = examples.get_example_data(data_method: :test_string)
    tokens = ex.map { |str| Emendate.lex(str) }
      .map { |t| t.types }
    ex.zip(tokens).to_h
  end

  # If no target is given, examples will be fully parsed
  # @param examples [Emendate::Examples::ExampleSet]
  # @!macro targetparam
  # @!macro optionsparam
  def parse_examples_for(examples: ExampleSet.new, target: nil, options: {})
    Emendate::Options.new(options) unless options.empty?
    ex = examples.get_example_data(data_method: :test_string)
    action = if target
      proc do
        ex.map do |str|
          puts str
          Emendate.prepped_for(string: str, target: target)
        end
      end
    else
      proc do
        ex.map do |str|
          puts str
          Emendate.process(str, options)
        end
      end
    end
    action.call
  end

  # stage should be a SegmentSet-holding instance variable of ProcessingManager
  def parsed_example_tokens(examples: ExampleSet.new, token_types: :all,
    stage: nil, options: {})
    parsed = parse_examples(examples: examples, stage: stage,
      options: options).reject do |pm|
      pm.state == :failed
    end
    processed = parsed.map(&:tokens)
    # rubocop:todo Layout/LineLength
    tokens = (token_types == :date) ? processed.map(&:date_part_types) : processed.map(&:types)
    # rubocop:enable Layout/LineLength
    ex = parsed.map { |pm| pm.orig_string }
    ex.zip(tokens)
  end

  def failed_to_parse(examples: ExampleSet.new)
    parse_examples(examples: examples)
      .select { |pm| pm.state == :failed }
      .map { |f| "#{f.orig_string} - #{f.errors.join("; ")}" }
  end

  # def example_tokens_by_str
  #   results = tokenize_examples.sort
  # rubocop:todo Layout/LineLength
  #   results.each{ |str, tokens| puts "#{str.ljust(example_length)}\t#{tokens.inspect}" }
  # rubocop:enable Layout/LineLength
  # end

  # def example_tokens_by_token
  #   results = tokenize_examples.sort_by{ |ex| ex[1] }
  # rubocop:todo Layout/LineLength
  #   results.each{ |str, tokens| puts "#{tokens.join(' ')}  -- String: #{str}" }
  # rubocop:enable Layout/LineLength
  # end

  # def parsed_tokens_by_token(data_set: '', stage: :final)
  # rubocop:todo Layout/LineLength
  #   results = parsed_example_tokens(data_set: data_set, stage: stage, date_type: date_type).sort_by{ |ex| ex[1] }
  # rubocop:enable Layout/LineLength
  # rubocop:todo Layout/LineLength
  #   results.each{ |str, tokens| puts "#{tokens.join(' ')}  -- String: #{str}" }
  # rubocop:enable Layout/LineLength
  # end

  # stage should be a SegmentSet-holding instance variable of ProcessingManager
  def unique_type_patterns(examples: ExampleSet.new, stage: nil, options: {})
    results = parsed_example_tokens(examples: examples, stage: stage,
      options: options)
    patterns = results.map do |parsed|
                 parsed[1]
               end.uniq.sort.map { |pattern| [pattern, []] }.to_h
    results.each { |r| patterns[r[1]] << r[0] }
    patterns.keys.sort.each do |pattern|
      puts pattern.join(" ")
      patterns[pattern].each { |e| puts "     " + e }
    end

    failed = failed_to_parse(examples: examples)
    return if failed.empty?

    puts "\n\n PARSING FAILURES"
    puts failed
  end

  def example_results(date_type: "", options: {})
    parse_examples(tag: tag, options: options).map(&:result)
  end
end
