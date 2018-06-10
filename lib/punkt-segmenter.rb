if RUBY_VERSION >= "2.4"
  $:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__))

  # Dependencies
  require "set"

  # Lib requires
  require "punkt-segmenter/frequency_distribution"
  require "punkt-segmenter/punkt"
else
  raise "This gem requires Ruby 2.4 or superior."
end
