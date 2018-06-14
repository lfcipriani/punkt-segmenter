Gem::Specification.new do |s|
  s.name          = "punkt-segmenter"
  s.version       = "1.0"
  s.platform      = Gem::Platform::RUBY
  s.summary       = "Ruby port of the NLTK Punkt sentence segmentation algorithm. Requires Ruby 2.3 or above."
  s.require_paths = ['lib']
  s.files         = Dir["{lib/**/*.rb,README.md,LICENSE.txt,test/**/*.rb,Rakefile,*.gemspec,script/*,data/*.json}"]

  s.author        = "Jacob Harris"
  s.email         = "harrisj.home@gmail.com"
  s.homepage      = "https://harrisj.github.io/"

  s.add_dependency('json')

  s.add_development_dependency('cover_me')
  s.add_development_dependency('minitest')
end
