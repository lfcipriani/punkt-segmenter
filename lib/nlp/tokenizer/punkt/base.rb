module Punkt
  class Base
    def initialize(language_vars = Punkt::LanguageVars.new, 
                   token_class   = Punkt::Token,
                   parameters    = Punkt::Parameters.new)
                   
      @parameters    = parameters
      @language_vars = language_vars
      @token_class   = token_class
    end
  
  private
    
    def tokenize_words(plain_text, &block)
      result = []
      paragraph_start = false
      plain_text.split("\n").each do |line|
        unless line.strip.empty?
          line_tokens = @language_vars.word_tokenize(line)
          first_token = @token_class.new(line_tokens.shift, 
                           :paragraph_start => paragraph_start,
                           :line_start      => true)
          paragraph_start = false
          line_tokens.map! { |token| @token_class.new(token) }.unshift(first_token)
          
          result += line_tokens
        else
          paragraph_start = true
        end
      end
      return result
    end
    
    def annotate_first_pass(tokens)
      tokens.each do |aug_token|
        tok = aug_token.token

        if @language_vars.sent_end_chars.include?(tok)
          aug_token.sentence_break = true
        elsif aug_token.is_ellipsis?
          aug_token.is_ellipsis = true
        elsif aug_token.ends_with_period? && !tok.end_with?("..")
          tok_low = UnicodeUtils.downcase(tok.chop)
          if @parameters.abbreviation_types.include?(tok_low) || @parameters.abbreviation_types.include?(tok_low.split("-")[-1])
            aug_token.abbr = true
          else
            aug_token.sentence_break = true
          end
        end

      end
    end
    
    def pair_each(list, &block)
      previous = list[0]
      list[1..list.size-1].each do |item|
        yield(previous, item)
        previous = item
      end
      yield(previous, nil)
    end
        
  end
end
