# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name    = 'gorgeous'
  gem.version = '0.1.2'

  # gem.add_dependency 'hpricot', '~> 0.8.2'
  # gem.add_development_dependency 'rspec', '~> 1.2.9'

  gem.summary = "Convert between different data formats; prettify JSON, HTML and XML"
  # gem.description = "Longer description."

  gem.authors  = ['Mislav Marohnić']
  gem.email    = 'mislav.marohnic@gmail.com'
  gem.homepage = 'https://github.com/mislav/gorgeous'

  gem.rubyforge_project = nil

  gem.executables = %w( gorgeous )
  gem.files = Dir['Rakefile', '{bin,lib,man,test,spec}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")
end
