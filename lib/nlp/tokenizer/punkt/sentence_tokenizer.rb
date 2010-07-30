module Punkt
  class SentenceTokenizer < Base
    def initialize(train_text,
                   language_vars = Punkt::LanguageVars.new, 
                   token_class   = Punkt::Token)
                   
      super(language_vars, token_class)
      
      if train_text.kind_of?(String)
        @parameters = train(train_text)
      elsif train_text.kind_of?(Punkt::Parameters) 
        @parameters = train_text
      end
    end
    
    def train(train_text)
      return train_text unless train_text.kind_of?(String)
      return Punkt::Trainer(train_text, @language_vars, @token_class).get_parameters
    end
    
    def tokenize(text, realign_boundaries = false)
      return sentences_from_text(text, realign_boundaries)
    end
    
    def sentences_from_text(text, realign_boundaries = false)
      result = []
      last_break = 0
      while match = @language_vars.re_period_context.match(text, last_break)
        context = match[0] + match[:after_tok]
        puts "#{context}"
        if text_contains_sentence_break?(context)
          result << text[last_break..match.end(0)]
          if match[:next_tok]
            last_break = match.begin(:next_tok)
          else
            last_break = match.end(0)
          end
        end
      end
      result << text[last_break..(text.size-1)]
    end
    
    def text_contains_sentence_break?(text)
      found = false
      annotate_tokens(tokenize_words(text)).each do |token|
        return true if found
        found = true if token.sentence_break
      end
      return false
    end
    
  private
  
    def annotate_tokens(tokens)
      tokens = annotate_first_pass(tokens)
      tokens = annotate_second_pass(tokens)
      return tokens
    end
    
    def annotate_second_pass(tokens)
      pair_each(tokens) do |tok1, tok2|
        next unless tok2
        next unless tok1.ends_with_period?
        
        token            = tok1.token
        type             = tok1.type_without_period
        next_token       = tok2.token
        next_type        = tok2.type_without_sentence_period
        token_is_initial = tok1.is_initial?
        
        
        puts "#{tok1} [secondpass] #{tok2}"
        if @parameters.collocations.include?([type, next_type])
          tok1.sentence_break = true
          tok1.abbr           = true
        end
        
        if (tok1.abbr || tok1.ellipsis) && !token_is_initial
          is_sentence_starter = orthographic_heuristic(tok2)
          if is_sentence_starter == true
            tok1.sentence_break = true
            next
          end
          
          if tok2.first_upper? && @parameters.sentence_starters.include?(next_type)
            tok1.sentence_break = true
            next
          end
        end
        
        if token_is_initial || type == "##number##"
          is_sentence_starter = orthographic_heuristic(tok2)
          if is_sentence_starter == false
            tok1.sentence_break = false
            tok1.abbr           = true
            next
          end
          
          if is_sentence_starter == :unknown && token_is_initial &&
             tok2.first_upper? && !(@parameters.orthographic_context[next_type] & Punkt::ORTHO_LC)
             tok1.sentence_break = false
             tok1.abbr           = true
          end
        end
        
      end
    end
    
    def orthographic_heuristic(aug_token)
      return false if [';', ',', ':', '.', '!', '?'].include?(aug_token.token)
      
      orthographic_context = @parameters.orthographic_context[aug_token.type_without_sentence_period]
      
      return true if aug_token.first_upper? && (orthographic_context & Punkt::ORTHO_LC) || !(orthographic_context & Punkt::ORTHO_MID_UC)
      return true if aug_token.first_lower? && (orthographic_context & Punkt::ORTHO_UC) || !(orthographic_context & Punkt::ORTHO_BEG_LC)
      
      return :unknown
    end
  
  end
end
