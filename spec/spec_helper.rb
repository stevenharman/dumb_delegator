if ENV["CODECLIMATE_REPO_TOKEN"]
  require "simplecov"
  SimpleCov.start
end

require File.expand_path('../lib/dumb_delegator', File.dirname(__FILE__))

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
