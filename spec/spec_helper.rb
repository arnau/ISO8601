# encoding: utf-8

$LOAD_PATH.unshift File.expand_path('..', __FILE__)
require 'iso8601'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.color = true
  config.order = 'random'
  config.formatter = :documentation
  # config.fail_fast = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
