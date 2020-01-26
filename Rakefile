#!/usr/bin/env rake
require "bundler/gem_tasks"

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--tag ~objectspace" if RUBY_PLATFORM == "java"
end

task default: :spec
