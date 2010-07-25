class FrequencyDistribution < Hash

  attr_reader :N

  alias_method :B      , :size
  alias_method :samples, :keys

  def initialize
    super
    clear
  end

  def clear
    super
    @N = 0
    @cache = {}
  end

  def [](sample)
    super || 0
  end

  def []=(sample, value)
    @N += (value - self[sample])
    super
    @cache = {}
  end

  def keys
    result = @cache[:ordered_by_frequency_desc] || order_by_frequency_desc
    result.map { |item| item[0] }
  end

  def values
    result = @cache[:ordered_by_frequency_desc] || order_by_frequency_desc
    result.map { |item| item[1] }
  end

  def items
    @cache[:ordered_by_frequency_desc] || order_by_frequency_desc
  end

  def each(&block)
    items = @cache[:ordered_by_frequency_desc] || order_by_frequency_desc
    items.each { |item| yield(item[0], item[1]) }
  end

  def each_key(&block)
    keys.each { |item| yield(item) }
  end

  def each_value(&block)
    values.each { |value| yield(value) }
  end

  def <<(sample)
    self.inc(sample)
  end

  def inc(sample, count = 1)
    return if count == 0
    self[sample] = self[sample] + count
  end
  
  def delete(sample, &block)
    result = super
    if result
      @cache = {}
      @N -= result
    end
    result
  end

  def delete_if(&block)
    raise "Not implemented for Frequency Distributions"
  end

  def frequency_of(sample)
    return 0 if @N == 0
    return self[sample].to_f / @N
  end

  def max
    unless @cache[:max]
      max_sample = nil
      max_count  = -1
      self.keys.each do |sample|
        if self[sample] > max_count
          max_sample = sample
          max_count  = self[sample]
        end
      end
      @cache[:max] = max_sample
    end
    return @cache[:max]
  end

  def merge(other_frequency_distribution)
    temp = self.dup
    other_frequency_distribution.each do |sample, value|
      temp.inc(sample, value)
    end
    return temp
  end

  def merge!(other_frequency_distribution)
    other_frequency_distribution.each do |sample, value|
      self.inc(sample, value)
    end
    self
  end

private
  
  def order_by_frequency_desc
    @cache[:ordered_by_frequency_desc] = self.to_a.sort {|x,y| y[1] <=> x[1] }
  end

end
