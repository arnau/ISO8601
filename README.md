# ISO8601

ISO8601 is a simple implementation of the ISO 8601 (Data elements and
interchange formats — Information interchange — Representation of dates and
times) standard.

## Build status

[![Build Status](https://secure.travis-ci.org/arnau/ISO8601.png?branch=master)](http://travis-ci.org/arnau/ISO8601/)


## Comments

### Duration sign

Because Durations and DateTime has a substraction method, Durations has
sign to be able to represent a negative value:

    (ISO8601::Duration.new('PT10S') - ISO8601::Duration.new('PT12S')).to_s  #=> '-PT2S'
    (ISO8601::Duration.new('-PT10S') + ISO8601::Duration.new('PT12S')).to_s #=> 'PT2S'

### Separators

Although, the spec allows three separator types: period (.), comma (,), and
raised period (·) by now I keep just the period option.


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

    atoms = ISO8601::DateTime.new('2014-05-31T10:11:12Z').to_a
    dt = DateTime.new(*atoms)


## Changes since 0.5

* `ISO8601::DateTime#century` no longer exists. Truncated representations were
removed in ISO 8601:2004.
* `ISO8601::DateTime#zone` delegates to core `DateTime#zone`.
* `ISO8601::DateTime#timezone` no longer exists. Now it delegates to
`DateTime#zone`.
* A date can have sign: `-1000-01-01`, `+2014-05-06T10:11:12Z`.
* A date time can be converted to an array of atoms with `#to_a`.


## TODO

* Decimal fraction in dateTime patterns
* Recurring time intervals
* Ordinal date pattern (YYYY-DDD)
* Week date pattern (YYYY-Www-D)
* Treat the `201005` as `2000-10-05` instead of `2010-05`


## Contributors

* [Nick Lynch](https://github.com/njlynch)
* [Pelle Braendgaard](https://github.com/pelle)
* [Takahiro Noda](https://github.com/tnoda)
* [Porras](https://github.com/porras)
* [Kenichi Kamiya](https://github.com/kachick)

## License

Arnau Siches under the [MIT License](https://github.com/arnau/ISO8601/blob/master/LICENSE)
