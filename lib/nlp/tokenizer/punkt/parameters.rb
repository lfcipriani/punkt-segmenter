module Punkt
  class Parameters
    
    attr_accessor :abbreviation_types
    attr_accessor :collocations
    attr_accessor :sentence_starters
    attr_accessor :orthographic_context
    
    def initialize
      clear_abbreviations
      clear_collocations
      clear_sentence_starters
      clear_orthographic_context
    end
    
    def clear_abbreviations
      @abbreviation_types   = Set.new
    end
    
    def clear_collocations
      @collocations         = Set.new
    end
    
    def clear_sentence_starters
      @sentence_starters    = Set.new
    end
    
    def clear_orthographic_context
      @orthographic_context = {}
    end
    
    def add_orthographic_context(type, flag)
      @orthographic_context[type] |= flag
    end
    
  end
end
