# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')
require "nlp/tokenizer/punkt"

class PunktTrainerTest < Test::Unit::TestCase

  def test_train_text
    text = File.read(File.expand_path(File.dirname(__FILE__) + "/../../data/abbr.txt"))
    trainer = Punkt::Trainer.new()
    trainer.train(text)
    tokenizer = Punkt::SentenceTokenizer.new(nil, trainer.get_parameters)
    puts tokenizer.tokenize(text).inspect
  end
  
end