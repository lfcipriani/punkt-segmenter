# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')
require "nlp/tokenizer/punkt"
require "benchmark"

class PunktTrainerTest < Test::Unit::TestCase

  def test_train_text
    text = File.read(File.expand_path(File.dirname(__FILE__) + "/../../data/abbr.txt"))
    result = 0
    puts Benchmark.measure {
      trainer = Punkt::Trainer.new()
      trainer.train(text)
      tokenizer = Punkt::SentenceTokenizer.new(trainer.get_parameters)
      result = tokenizer.tokenize(text)
    }
    
    require "ap"
    ap result
  end
  
end