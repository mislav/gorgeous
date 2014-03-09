# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name    = 'gorgeous'
  gem.version = '0.2.0'

  gem.add_dependency 'nokogiri'
  gem.add_dependency 'activesupport'
  gem.add_dependency 'rack'
  gem.add_dependency 'mail'

  gem.summary = "Convert between different data formats; prettify JSON, HTML and XML"

  gem.authors  = ['Mislav Marohnić']
  gem.email    = 'mislav.marohnic@gmail.com'
  gem.homepage = 'https://github.com/mislav/gorgeous#readme'

  gem.executables = %w( gorgeous )
  gem.files = Dir['Rakefile', '{bin,lib,man,test,spec}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")
end
