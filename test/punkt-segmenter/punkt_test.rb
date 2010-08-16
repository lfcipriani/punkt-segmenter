# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class PunktTest < Test::Unit::TestCase

  def test_number_of_sentences
    text = File.read(File.expand_path(File.dirname(__FILE__) + "/../data/canudos.txt"))
    
    trainer = Punkt::Trainer.new()
    trainer.train(text)
    tokenizer = Punkt::SentenceTokenizer.new(trainer.parameters)
    result = tokenizer.sentences_from_text(text, :output => :sentences_text, :realign_boundaries => true)
    
    #TODO: marshalizar o trainer, e nao o segmenter
        
    assert_equal 45, result.size
  end

end

