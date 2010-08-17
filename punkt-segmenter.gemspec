Gem::Specification.new do |s|
  s.name          = "punkt-segmenter"
  s.version       = "0.9.0"
  s.platform      = Gem::Platform::RUBY
  s.summary       = "Ruby port of the NLTK Punkt sentence segmentation algorithm"
  s.require_paths = ['lib']
  s.files         = Dir["{lib/**/*.rb,README.md,LICENSE.txt,test/**/*.rb,Rakefile,*.gemspec,script/*}"] 
  
  s.author        = "Luis Cipriani"
  s.email         = "lfcipriani@talleye.com"
  s.homepage      = "http://blog.talleye.com"
  
  s.add_dependency('unicode_utils', '>= 1.0.0')
  
  s.add_development_dependency('cover_me')
  s.add_development_dependency('ruby-debug19')
end
