$:.unshift File.join(File.dirname(__FILE__), "..", "lib")


Dir["iso8601/**/test_*.rb"].each { |test| load test }