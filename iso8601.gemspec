# encoding: utf-8

$:.push File.expand_path('../lib', __FILE__)
require 'iso8601'

Gem::Specification.new do |s|
  s.name        = 'iso8601'
  s.version     = ISO8601::VERSION
  s.authors     = ['Arnau Siches']
  s.email       = 'arnau.siches@gmail.com'
  s.homepage    = 'https://github.com/arnau/ISO8601'
  s.summary     = "Ruby parser to work with ISO 8601 dateTimes and durations - http://en.wikipedia.org/wiki/ISO_8601"
  s.description = <<-EOD
    ISO8601 is a simple implementation in Ruby of the ISO 8601 (Data elements and 
    interchange formats - Information interchange - Representation of dates 
    and times) standard.
  EOD
  s.license = 'MIT'
  s.rubyforge_project = 'iso8601'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']
end
