# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class PunktTrainerTest < Minitest::Test

  def test_train_basic_portuguese_text_with_error
    not_so_good_trainning_data = File.read(File.expand_path(File.dirname(__FILE__) + "/../../data/canudos.txt"))

    trainer = Punkt::Trainer.new()
    trainer.train(not_so_good_trainning_data)

    parameters = trainer.parameters

    # 'gol' is a word, not an abbreviation, the trainning text isn't good enough
    assert parameters.abbreviation_types.include?("gol")
  end

  def test_improve_trainning_of_portuguese_text
    not_so_good_trainning_data = File.read(File.expand_path(File.dirname(__FILE__) + "/../../data/canudos.txt"))
    text_with_gol_as_a_word    = File.read(File.expand_path(File.dirname(__FILE__) + "/../../data/gripe.txt"))

    trainer = Punkt::Trainer.new()
    trainer.train(not_so_good_trainning_data)
    trainer.train(text_with_gol_as_a_word)

    parameters = trainer.parameters

    # 'gol' is a word now, the trainning was better
    assert !parameters.abbreviation_types.include?("gol")
  end
end
