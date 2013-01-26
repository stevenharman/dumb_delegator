# -*- encoding: utf-8 -*-
require File.expand_path('../lib/dumb_delegator/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Andy Lindeman', 'Steven Harman']
  gem.email         = ['alindeman@gmail.com', 'steveharman@gmail.com']
  gem.description   = %q{Delegator class that delegates ALL the things}
  gem.summary       = <<-EOD
    Delegator and SimpleDelegator in Ruby's stdlib are somewhat useful, but they pull in most of Kernel. This is not appropriate for many uses; for instance, delegation to Rails models.
  EOD
  gem.homepage      = 'https://github.com/stevenharman/dumb_delegator'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'dumb_delegator'
  gem.require_paths = ['lib']
  gem.version       = DumbDelegator::VERSION

  gem.add_development_dependency 'rspec', '~>2.11.0'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'rake'
end
