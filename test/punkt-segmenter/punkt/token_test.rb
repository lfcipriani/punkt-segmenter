# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class PunktTokenTest < Test::Unit::TestCase

  def test_token_properties_initialization
    token = Punkt::Token.new("Test", :paragraph_start => true, 
                                     :line_start => true, 
                                     :sentence_break => true, 
                                     :abbr => false)

    assert_equal true,  token.paragraph_start
    assert_equal true,  token.line_start
    assert_equal true,  token.sentence_break
    assert_equal false, token.abbr
    assert_equal nil,   token.ellipsis
  end
  
  def test_main_attributes
    token = Punkt::Token.new("Test")
    assert_equal "test", token.type

    token = Punkt::Token.new("Test.")
    assert_equal "test.", token.type
    
    token = Punkt::Token.new("Índico")
    assert_equal "índico", token.type
  end
  
  def test_type_without_period
    token = Punkt::Token.new("Test")
    assert_equal "test", token.type_without_period
    
    token = Punkt::Token.new("Test.")
    assert_equal "test", token.type_without_period
    
    token = Punkt::Token.new("123.")
    assert_equal "##number##", token.type_without_period
  end
  
  def test_type_without_sentence_period
    token = Punkt::Token.new("Test", :sentence_break => false)
    assert_equal "test", token.type_without_sentence_period
    
    token = Punkt::Token.new("test.", :sentence_break => true)
    assert_equal "test", token.type_without_sentence_period
  end
  
  def test_first_upper?    
    token = Punkt::Token.new("Test")
    assert token.first_upper? 

    token = Punkt::Token.new("Índico")
    assert token.first_upper? 
    
    token = Punkt::Token.new("test.")
    assert !token.first_upper?
  end

  def test_first_lower?    
    token = Punkt::Token.new("Test")
    assert !token.first_lower? 

    token = Punkt::Token.new("Índico")
    assert !token.first_lower? 
    
    token = Punkt::Token.new("test.")
    assert token.first_lower?
  end

  def test_first_case    
    token = Punkt::Token.new("Test")
    assert_equal :upper, token.first_case

    token = Punkt::Token.new("Índico")
    assert_equal :upper, token.first_case

    token = Punkt::Token.new("test.")
    assert_equal :lower, token.first_case
    
    token = Punkt::Token.new("@")
    assert_equal :none, token.first_case
  end
  
  def test_is_ellipsis?
    token = Punkt::Token.new("...")
    assert token.is_ellipsis?

    token = Punkt::Token.new("..")
    assert token.is_ellipsis?

    token = Punkt::Token.new("..foo")
    assert !token.is_ellipsis?    
  end

  def test_is_initial?
    token = Punkt::Token.new("C.")
    assert token.is_initial?

    token = Punkt::Token.new("B.M.")
    assert !token.is_initial?
  end

  def test_is_alpha?
    token = Punkt::Token.new("foo")
    assert token.is_alpha?

    token = Punkt::Token.new("!")
    assert !token.is_alpha?    
  end
  
  def test_is_non_punctuation?
    token = Punkt::Token.new("foo")
    assert token.is_non_punctuation?

    token = Punkt::Token.new("!")
    assert !token.is_non_punctuation?
  end
  
  def test_to_s_and_inspect
    token = Punkt::Token.new("foo", :abbr => true, :sentence_break => true, :ellipsis => true)
    
    assert_equal "<foo<A><E><S>>", token.inspect
  end
  
end

