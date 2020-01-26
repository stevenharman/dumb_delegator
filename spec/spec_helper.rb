if ENV["CC_TEST_REPORTER_ID"]
  require "simplecov"
  SimpleCov.start
end

require "pry"
require File.expand_path("../lib/dumb_delegator", File.dirname(__FILE__))

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
