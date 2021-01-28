# frozen_string_literal: true

module Emendate
  
  class FormatStandardizer
  attr_reader :orig, :result, :standardizable
    def initialize(tokens:)
      @orig = tokens
      @result = tokens.clone
      @standardizable = true
    end

    def standardize
      while standardizable
        s = determine_standardizer
        break if s.nil?
        send(s)
      end
      result
    end

    private

    def determine_standardizer
      s = partial_match_standardizers
      return s unless s.nil?

      s = full_match_standardizers
      standardizable = false if s.nil?
      s
    end

    def partial_match_standardizers
      case result.type_string
      when /.*partial hyphen.*/
        :remove_post_partial_hyphen
      when /.*number_month number1or2 comma (number3|number4).*/
        :remove_post_month_comma
      end
    end
    
    def full_match_standardizers
      case result.date_part_types
      when %i[number1or2 number1or2 century]
        :alternate_centuries
      end
    end
    
    def alternate_centuries
      century = result[-1].dup
      centuryless = result.select{ |t| t.type == :number1or2 }.first
      ins_pt = result.find_index(centuryless) + 1
      result.insert(ins_pt, century)
    end

    def remove_post_month_comma
      commas = result.select do |t|
        t.type == :comma &&
           result[result.find_index(t) - 2].type == :number_month &&
          result[result.find_index(t) - 1].type == :number1or2 &&
          ( result[result.find_index(t) + 1].type == :number3 ||
            result[result.find_index(t) + 1].type == :number4 )
      end
      commas.map{ |c| result.find_index(c) }
        .sort.reverse
        .each{ |i| result.delete_at(i) }
    end
    
    def remove_post_partial_hyphen
      partial = result.select{ |t| t.type == :partial && result[result.find_index(t) + 1].type == :hyphen }.first
      hyphen_ind = result.find_index(partial) + 1
      result.delete_at(hyphen_ind)
    end

  end
end
