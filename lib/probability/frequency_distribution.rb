class FrequencyDistribution < Hash

  attr_reader :N

  alias_method :B, :size

  #TODO: add sorted keys list, sorted value list, to_s
  def initialize
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

  def <<(sample)
    self.inc(sample)
  end

  def inc(sample, count = 1)
    return if count == 0
    self[sample] = self[sample] + count
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
    other_frequency_distribution.each do |sample, value|
      self.inc(sample, value)
    end
  end

end
