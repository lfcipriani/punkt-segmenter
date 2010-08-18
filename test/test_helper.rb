if ENV["coverage"]
  require 'cover_me'
  CoverMe.config do |c|
      # where is your project's root:
      c.project.root = File.expand_path(File.dirname(__FILE__) + '/..')

      # what files are you interested in coverage for:
      c.file_pattern = /(#{CoverMe.config.project.root}\/lib\/.+\.rb)/ix
  end
end

require 'test/unit'
require 'rubygems'
require 'ruby-debug'

require File.expand_path(File.dirname(__FILE__) + '/../lib/punkt-segmenter')