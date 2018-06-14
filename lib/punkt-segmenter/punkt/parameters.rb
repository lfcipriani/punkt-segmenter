require 'rubygems'
require 'json'

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
      @orthographic_context = Hash.new(0)
    end
    
    def add_orthographic_context(type, flag)
      @orthographic_context[type] |= flag
    end

    def self.load_language(language)
      data_path = File.join(File.dirname(__FILE__), "..", "..", "..", "data", "#{language}.json")

      json_body = ""
      open(data_path) {|file| json_body = file.read }
      json = JSON.parse(json_body)

      # let's load
      p = new

      json["sentence_starters"].each {|s| p.sentence_starters << s}
      json["abbrev_types"].each {|a| p.abbreviation_types << a}
      json["collocations"].each {|a| p.collocations << a}

      json["ortho_context"].each {|k,v| p.orthographic_context[k] = v }

      p
    end
  end
end
