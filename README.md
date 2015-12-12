# ISO8601

Check the [changelog](https://github.com/arnau/ISO8601/blob/master/CHANGELOG.md) if you are upgrading from an older version.

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/arnau/ISO8601?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

ISO8601 is a simple implementation of the ISO 8601 (Data elements and
interchange formats — Information interchange — Representation of dates and
times) standard.

## Build status

[![Build Status](https://secure.travis-ci.org/arnau/ISO8601.png?branch=master)](http://travis-ci.org/arnau/ISO8601/)
[![Dependency Status](https://gemnasium.com/arnau/ISO8601.svg)](https://gemnasium.com/arnau/ISO8601)
[![Gem Version](https://badge.fury.io/rb/iso8601.svg)](http://badge.fury.io/rb/iso8601)

## Supported versions

* MRI 2.x
* RBX 2
* JRuby 9

## Documentation

Check the [rubydoc documentation](http://www.rubydoc.info/gems/iso8601).

* [Time intervals](docs/time-intervals.md)

## Comments about this implementation

### Duration sign

Because `Durations` and `DateTime` have a substraction method, `Durations` has
sign to be able to represent negative values:

    (ISO8601::Duration.new('PT10S') - ISO8601::Duration.new('PT12S')).to_s  #=> '-PT2S'
    (ISO8601::Duration.new('-PT10S') + ISO8601::Duration.new('PT12S')).to_s #=> 'PT2S'

### Fractional seconds precision

Fractional seconds for `ISO8601::DateTime` and `ISO8601::Time` are rounded to
one decimal.

    ISO8601::DateTime.new('2015-02-03T10:11:12.12').second #=> 12.1
    ISO8601::Time.new('T10:11:12.16').second #=> 12.2


## Differences with core Date, Time and DateTime

Core `Date.parse` and `DateTime.parse` doesn't allow reduced precision. For
example:

    DateTime.parse('2014-05') # => ArgumentError: invalid date

But the standard covers this situation assuming any missing piece as its lower
value:

    ISO8601::DateTime.new('2014-05').to_s # => "2014-05-01T00:00:00+00:00"
    ISO8601::DateTime.new('2014').to_s # => "2014-01-01T00:00:00+00:00"

The same assumption happens in core classes with `.new`:

    DateTime.new(2014,5) # => #<DateTime: 2014-05-01T00:00:00+00:00 ((2456779j,0s,0n),+0s,2299161j)>
    DateTime.new(2014) # => #<DateTime: 2014-01-01T00:00:00+00:00 ((2456659j,0s,0n),+0s,2299161j)>


The value of second in core classes are handled by two methods: `#second` and
`#second_fraction`:

    dt = DateTime.parse('2014-05-06T10:11:12.5')
    dt.second # => 12
    dt.second_fraction # => (1/2)

This gem approaches second fraction using floats:

    dt = ISO8601::DateTime.new('2014-05-06T10:11:12.5')
    dt.second # => 12.5

Unmatching precison is handled strongly. Notice the time fragment is lost in
`DateTime.parse` without warning only if the loose precision is in the time
component.

    ISO8601::DateTime.new('2014-05-06T101112')  # => ISO8601::Errors::UnknownPattern
    DateTime.parse('2014-05-06T101112')  # => #<DateTime: 2014-05-06T00:00:00+00:00 ((2456784j,0s,0n),+0s,2299161j)>

    ISO8601::DateTime.new('20140506T10:11:12')  # => ISO8601::Errors::UnknownPattern
    DateTime.parse('20140506T10:11:12')  # => #<DateTime: 2014-05-06T10:11:12+00:00 ((2456784j,0s,0n),+0s,2299161j)>


`DateTime#to_a` allow decomposing to an array of atoms:

    atoms = ISO8601::DateTime.new('2014-05-31T10:11:12Z').to_a # => [2014, 5, 31, 10, 11, 12, '+00:00']
    dt = DateTime.new(*atoms)

Ordinal dates keep the sign. `2014-001` is not the same as `-2014-001`.

Week dates raise an error when two digit days provied instead of return monday:

    ISO8601::DateTime.new('2014-W15-02') # => ISO8601::Errors::UnknownPattern
    DateTime.new('2014-W15-02')  # => #<Date: 2014-04-07 ((2456755j,0s,0n),+0s,2299161j)>


## Compatibility with core classes

Each ISO8601 class has a method `to_*` to convert to its core equivalent:

`ISO8601::DateTime#to_datetime` -> `DateTime` (it actually delegates a couple of
methods from `DateTime`).  Check `lib/iso8601/date_time.rb:13`.

`ISO8601::Date#to_date` -> `Date` (it actually delegates to a couple of methods
from `Date`).  Check `lib/iso8601/date.rb:18`

`ISO8601::Time#to_time` -> `Time` (it actually delegates to a couple of methods
from `Time`).  Check `lib/iso8601/time.rb:15`

`ISO8601::Atom#to_f` -> `Float`, `ISO8601::Atom#to_i` -> `Integer`


## Testing


### Docker

    # Install Docker
    $ make install
    $ make test

You can alse target specific runtimes:

    $ make mri-test
    $ make rbx-test
    $ make jruby-test

### Raw

The old fashion way:

    # Install a Ruby flavour
    $ bundle install
    $ bundle exec rspec


## Contributing

[Contributors](https://github.com/arnau/ISO8601/graphs/contributors)

Please see [CONTRIBUTING.md](./CONTRIBUTING.md)

## License

Arnau Siches under the [MIT License](https://github.com/arnau/ISO8601/blob/master/LICENSE)
