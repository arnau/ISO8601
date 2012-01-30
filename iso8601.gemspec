# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "iso8601"

Gem::Specification.new do |s|
  s.name        = "iso8601"
  s.version     = ISO8601::VERSION
  s.authors     = ["Arnau Siches"]
  s.email       = ["arnau.siches@gmail.com"]
  s.homepage    = "https://github.com/arnau/ISO8601"
  s.summary     = %q{Ruby parser to work with ISO8601 dateTimes and durations — http://en.wikipedia.org/wiki/ISO_8601y}
  s.description = %q{ISO8601 is a simple implementation of the ISO 8601 (Data elements and
  interchange formats — Information interchange — Representation of dates and
  times) standard.}

  s.rubyforge_project = "iso8601"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
