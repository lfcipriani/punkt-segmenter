# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class PunktTest < Test::Unit::TestCase

  def setup
    @text      = File.read(File.expand_path(File.dirname(__FILE__) + "/../data/wikipedia_minute.txt"))
    @tokenizer = Punkt::SentenceTokenizer.new(@text)
  end

  def test_sentences_as_string_indexes
    result = @tokenizer.sentences_from_text(@text)
    
    assert_equal 7        , result.size #number of sentences
    assert_equal [0,53]   , result.first
    assert_equal [478,595], result.last
  end
  
  def test_sentences_as_list_of_strings
    result = @tokenizer.sentences_from_text(@text, :output => :sentences_text)
    
    assert_equal 7        , result.size #number of sentences
    assert_equal result[0], "A minute is a unit of measurement of time or of angle."
    assert_equal result[1], "The minute is a unit of time equal to 1/60th of an hour or 60 seconds by 1."
    assert_equal result[2], "In the UTC time scale, a minute occasionally has 59 or 61 seconds; see leap second."
    assert_equal result[3], "The minute is not an SI unit; however, it is accepted for use with SI units."
    assert_equal result[4], "The symbol for minute or minutes is min."
    assert_equal result[5], "The fact that an hour contains 60 minutes is probably due to influences from the Babylonians, who used a base-60 or sexagesimal counting system."
    assert_equal result[6], "Colloquially, a min. may also refer to an indefinite amount of time substantially longer than the standardized length."
  end
  
  def test_sentences_as_list_of_tokens
    result = @tokenizer.sentences_from_text(@text, :output => :tokenized_sentences)
    
    assert_equal 7       , result.size #number of sentences
    assert_equal "angle.", result.first.last
    assert_equal 18      , result[1].size
    assert_equal String  , result.last.first.class
  end

  def test_segment_list_of_tokens
    list_of_tokens = Punkt::Base.new().tokenize_words(@text, :output => :string)
    @tokenizer     = Punkt::SentenceTokenizer.new(@text)
    result         = @tokenizer.sentences_from_tokens(list_of_tokens)
    
    assert_equal 7       , result.size #number of sentences
    assert_equal "angle.", result.first.last
    assert_equal 18      , result[1].size
    assert_equal String  , result.last.first.class
  end
  
  def test_realign_boundaries
    text      = File.read(File.expand_path(File.dirname(__FILE__) + "/../data/canudos.txt"))    
    tokenizer = Punkt::SentenceTokenizer.new(text)
    result    = tokenizer.sentences_from_text(text, :output => :sentences_text)
    
    assert result[7].end_with?("(que vem bem ao nosso caso.")
    assert result[8].start_with?(") \n\nDizem que durante")
    
    result    = tokenizer.sentences_from_text(text, :output => :sentences_text, :realign_boundaries => true)

    assert result[7].end_with?("(que vem bem ao nosso caso.)")
    assert result[8].start_with?("Dizem que durante")    
  end

end

