if RUBY_VERSION >= "1.9"
  $:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__))

  # Dependencies
  require "unicode_utils"
  require "set"

  # Lib requires
  require "punkt-segmenter/frequency_distribution"
  require "punkt-segmenter/punkt"
else
  raise "This gem requires Ruby 1.9 or superior."
end