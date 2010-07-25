require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')
require "nlp/tokenizer/punkt/language_vars"

class PunktLanguageVarsTest < Test::Unit::TestCase

  def setup
    @lang_var = Punkt::LanguageVars.new
    @sample = %Q{For example, the word "abbreviation" can itself be represented by the abbreviation abbr., abbrv. or abbrev.}
  end

  def test_word_tokenize
    tokens = @lang_var.word_tokenize(@sample)

    assert_equal 20  , tokens.size
    assert_equal true, tokens.include?("abbr.")
    assert_equal true, tokens.include?("\"")
    assert_equal true, tokens.include?(",")
    assert_equal true, tokens.include?("itself")
  end

end

