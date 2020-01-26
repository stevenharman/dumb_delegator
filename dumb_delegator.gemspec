# -*- encoding: utf-8 -*-
require File.expand_path('../lib/dumb_delegator/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name = "dumb_delegator"
  gem.version = DumbDelegator::VERSION
  gem.required_ruby_version = ">= 2.4.0"
  gem.authors       = ['Andy Lindeman', 'Steven Harman']
  gem.email         = ['alindeman@gmail.com', 'steven@harmanly.com']
  gem.description   = %q{Delegator class that delegates ALL the things}
  gem.summary       = <<-EOD
    Delegator and SimpleDelegator in Ruby's stdlib are somewhat useful, but they pull in most of Kernel. This is not appropriate for many uses; for instance, delegation to Rails models.
  EOD
  gem.homepage      = 'https://github.com/stevenharman/dumb_delegator'

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency "pry"
  gem.add_development_dependency "rake", "~> 13.0"
  gem.add_development_dependency "rspec", "~> 3.9"
end
