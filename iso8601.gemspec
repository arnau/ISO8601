# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'iso8601/version'

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |s|
  s.name = 'iso8601'
  s.version = ISO8601::VERSION
  s.date = Time.now.strftime('%Y-%m-%d')
  s.authors = ['Arnau Siches']
  s.email = 'arnau.siches@gmail.com'
  s.homepage = 'https://github.com/arnau/ISO8601'
  s.summary = "Ruby parser to work with ISO 8601 dateTimes and durations - http://en.wikipedia.org/wiki/ISO_8601"
  s.description = <<-DESC
    ISO8601 is a simple implementation in Ruby of the ISO 8601 (Data elements and
    interchange formats - Information interchange - Representation of dates
    and times) standard.
  DESC
  s.license = 'MIT'
  s.files = Dir['{docs,lib}/**/*', 'LICENSE', 'README.md']
  s.test_files = Dir['spec/**/*']
  s.require_paths = ['lib']

  s.metadata["yard.run"] = "yri"
  s.required_ruby_version = '>= 2.0.0'
  s.add_development_dependency 'rspec', '~> 3.9'
  s.add_development_dependency 'rubocop', '~> 0.85'
  s.add_development_dependency 'rubocop-packaging', '~> 0.1.1'
  s.add_development_dependency 'pry', '~> 0.13.1'
  s.add_development_dependency 'pry-doc', '~> 1.1.0'
end
