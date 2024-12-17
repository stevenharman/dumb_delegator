require File.expand_path("../lib/dumb_delegator/version", __FILE__)

Gem::Specification.new do |spec|
  spec.name = "dumb_delegator"
  spec.version = DumbDelegator::VERSION
  spec.required_ruby_version = ">= 2.4.0"
  spec.authors = ["Andy Lindeman", "Steven Harman"]
  spec.email = ["alindeman@gmail.com", "steven@harmanly.com"]
  spec.licenses = ["MIT"]
  spec.summary = "Delegator class that delegates ALL the things"
  spec.description = <<~EOD
    Delegator and SimpleDelegator in Ruby's stdlib are useful, but they pull in most of Kernel.
    This is not appropriate for many uses; for instance, delegation to Rails Models.
    DumbDelegator, on the other hand, delegates nearly everything to the wrapped object.
  EOD
  spec.homepage = "https://github.com/stevenharman/dumb_delegator"

  spec.metadata = {
    "changelog_uri" => "https://github.com/stevenharman/dumb_delegator/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://rubydoc.info/gems/dumb_delegator",
    "homepage_uri" => spec.homepage,
    "source_code_uri" => "https://github.com/stevenharman/dumb_delegator"
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ spec/ .git .github Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
