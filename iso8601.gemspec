# encoding: utf-8

$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'iso8601/version'

Gem::Specification.new do |s|
  s.name = 'iso8601'
  s.version = ISO8601::VERSION
  s.date = Time.now.strftime('%Y-%m-%d')
  s.authors = ['Arnau Siches']
  s.email = 'arnau.siches@gmail.com'
  s.homepage = 'https://github.com/arnau/ISO8601'
  s.summary = "Ruby parser to work with ISO 8601 dateTimes and durations - http://en.wikipedia.org/wiki/ISO_8601"
  s.description = <<-EOD
    ISO8601 is a simple implementation in Ruby of the ISO 8601 (Data elements and
    interchange formats - Information interchange - Representation of dates
    and times) standard.
  EOD
  s.license = 'MIT'
  s.rubyforge_project = 'iso8601'
  s.files = %W(CHANGELOG.md
               CONTRIBUTING.md
               Gemfile
               LICENSE
               README.md
               Rakefile
               iso8601.gemspec
               docs/date-time.md
               docs/duration.md
               docs/time-interval.md
               lib/iso8601.rb
               lib/iso8601/atomic.rb
               lib/iso8601/date.rb
               lib/iso8601/date_time.rb
               lib/iso8601/days.rb
               lib/iso8601/duration.rb
               lib/iso8601/errors.rb
               lib/iso8601/hours.rb
               lib/iso8601/minutes.rb
               lib/iso8601/months.rb
               lib/iso8601/seconds.rb
               lib/iso8601/time.rb
               lib/iso8601/time_interval.rb
               lib/iso8601/version.rb
               lib/iso8601/weeks.rb
               lib/iso8601/years.rb
               spec/iso8601/date_spec.rb
               spec/iso8601/date_time_spec.rb
               spec/iso8601/days_spec.rb
               spec/iso8601/duration_spec.rb
               spec/iso8601/hours_spec.rb
               spec/iso8601/minutes_spec.rb
               spec/iso8601/months_spec.rb
               spec/iso8601/seconds_spec.rb
               spec/iso8601/time_interval_spec.rb
               spec/iso8601/time_spec.rb
               spec/iso8601/weeks_spec.rb
               spec/iso8601/years_spec.rb
               spec/spec_helper.rb)
  s.test_files = s.files.grep(%r{^spec/})
  s.require_paths = ['lib']

  s.has_rdoc = 'yard'
  s.required_ruby_version = '>= 2.0.0'
  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'rubocop', '~> 0.40'
  s.add_development_dependency 'pry', '~> 0.10.3'
  s.add_development_dependency 'pry-doc', '~> 0.8.0'
end
