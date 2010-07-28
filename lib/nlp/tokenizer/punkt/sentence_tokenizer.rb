module Punkt
  class SentenceTokenizer < Base
    def initialize(train_text    = nil,
                   language_vars = Punkt::LanguageVars.new, 
                   token_class   = Punkt::Token)
                   
      super(language_vars, token_class)
            
      train(train_text, true) if train_text
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
      while match = l.re_period_context.match(s, last_break)
        context = match[0] + match[:after_tok]
        if text_contains_sentence_break?(context)
          #TODO continuar
        end
      end
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
  
  end
end
