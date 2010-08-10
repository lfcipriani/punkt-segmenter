require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require "nlp/tokenizer/punkt"

class PunktTest < Test::Unit::TestCase

  def test_number_of_sentences
    text = File.read(File.expand_path(File.dirname(__FILE__) + "/../data/abbr.txt"))
    
    trainer = Punkt::Trainer.new()
    trainer.train(text)
    tokenizer = Punkt::SentenceTokenizer.new(trainer.get_parameters)
    result = tokenizer.tokenize(text, true)
    
    assert_equal 45, result.size
  end

end

