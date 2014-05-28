# encoding: utf-8

$:.unshift File.expand_path('..', __FILE__)
require 'iso8601'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.color = true
  config.order = 'random'
  config.formatter = :documentation
  # config.fail_fast = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end
