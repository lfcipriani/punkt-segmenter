require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require "nlp/probability/frequency_distribution"

class FrequencyDistributionTest < Test::Unit::TestCase

  def setup
    @words = %w(two one three one one three two one two)
    @freq_dist = FrequencyDistribution.new
  end

  def test_increment_count_on_given_sample
    @words.each { |word| @freq_dist << word }

    assert_equal @freq_dist["one"]  , 4
    assert_equal @freq_dist["two"]  , 3
    assert_equal @freq_dist["three"], 2
    assert_equal @freq_dist.N       , 9
  end

  def test_increment_count_on_given_sample_for_count_different_than_1
    @words.each { |word| @freq_dist.inc(word, 2) }

    assert_equal @freq_dist["one"]  , 8
    assert_equal @freq_dist["two"]  , 6
    assert_equal @freq_dist["three"], 4
    assert_equal @freq_dist.N       , 18
  end

  def test_direct_count_attribution
    @freq_dist["one"] = 10
    @freq_dist["two"] = 20
    @freq_dist["three"] = 30

    assert_equal @freq_dist["one"]  , 10
    assert_equal @freq_dist["two"]  , 20
    assert_equal @freq_dist["three"], 30
    assert_equal @freq_dist.N       , 60
  end

  def test_get_sample_frequencies
    @words.each { |word| @freq_dist << word }

    assert_equal((@freq_dist.frequency_of("one") + 
                 @freq_dist.frequency_of("two") + 
                 @freq_dist.frequency_of("three")).round, 1)
  end

  def test_get_sample_with_maximum_ocurrences
    @words.each { |word| @freq_dist << word }
    
    assert_equal(@freq_dist.max, "one")
  end

  def test_merge_frequency_distribution
    @words.each { |word| @freq_dist << word }
    @new_freq = @freq_dist.merge(@freq_dist)

    assert_equal @new_freq["one"]  , 8
    assert_equal @new_freq["two"]  , 6
    assert_equal @new_freq["three"], 4
    assert_equal @new_freq.N       , 18

    assert_equal @freq_dist.merge!(@new_freq).N, 27
  end

  def test_get_keys_ordered_by_frequency_desc
    @words.each { |word| @freq_dist << word }
    
    assert_equal @freq_dist.keys.first, "one"
    assert_equal @freq_dist.keys[1]   , "two"
    assert_equal @freq_dist.keys.last , "three"
 end

  def test_get_values_ordered_by_frequency_desc
    @words.each { |word| @freq_dist << word }
    
    assert_equal @freq_dist.values.first, 4
    assert_equal @freq_dist.values[1]   , 3
    assert_equal @freq_dist.values.last , 2
  end

  def test_iterators_must_order_by_frequency_desc
    @words.each { |word| @freq_dist << word }
    ordered = []
    @freq_dist.each do |sample, value| 
      ordered << [sample, value]
    end
    assert_equal ordered, @freq_dist.items

    ordered = []
    @freq_dist.each_key do |keys| 
      ordered << keys
    end
    assert_equal ordered, @freq_dist.keys

    ordered = []
    @freq_dist.each_value do |value| 
      ordered << value
    end
    assert_equal ordered, @freq_dist.values
  end

  def test_removing_samples
    @words.each { |word| @freq_dist << word }
    
    assert_equal @freq_dist.delete("one"), 4
    assert_equal @freq_dist.N            , 5

    assert_raise(RuntimeError) { @freq_dist.delete_if { |sample, value| value == 2 } }
  end

  def test_features_with_empty_distribution
    assert_equal @freq_dist["a sample"]             , 0
    assert_equal @freq_dist.N                       , 0
    assert_equal @freq_dist.frequency_of("a sample"), 0
    assert_equal @freq_dist.max                     , nil
  end
end

