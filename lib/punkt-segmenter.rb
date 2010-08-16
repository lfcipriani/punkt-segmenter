$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__))

# Dependencies
require "unicode_utils"
require "set"

# Lib requires
require "punkt-segmenter/frequency_distribution"
require "punkt-segmenter/punkt"