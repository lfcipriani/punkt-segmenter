require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require "tokenizer/punkt"

class PunktTest < Test::Unit::TestCase

  def setup
    punkt = Punkt.new
  end

  def test_simple
    assert true
  end

end

