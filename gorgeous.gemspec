# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name    = 'gorgeous'
  gem.version = '0.1.0'
  gem.date    = Time.now.strftime('%Y-%m-%d')

  # gem.add_dependency 'hpricot', '~> 0.8.2'
  # gem.add_development_dependency 'rspec', '~> 1.2.9'

  gem.summary = "Convert between different data formats"
  # gem.description = "Longer description."

  gem.authors  = ['Mislav Marohnić']
  gem.email    = 'mislav.marohnic@gmail.com'
  gem.homepage = 'http://github.com/mislav/gorgeous'

  gem.rubyforge_project = nil
  gem.has_rdoc = false
  # gem.rdoc_options = ['--main', 'README.rdoc', '--charset=UTF-8']
  # gem.extra_rdoc_files = ['README.rdoc', 'LICENSE', 'CHANGELOG.rdoc']

  gem.executables = %w( gorgeous )
  gem.files = Dir['Rakefile', '{bin,lib,man,test,spec}/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")
end
