# ISO8601

ISO8601 is a simple implementation of the ISO 8601 (Data elements and 
interchange formats — Information interchange — Representation of dates and 
times) standard.

## Build status

[![Build Status](https://secure.travis-ci.org/arnau/ISO8601.png?branch=master)](http://travis-ci.org/arnau/ISO8601/)


## Comments

### Duration sign

Because Durations and DateTime has a substraction method, Durations has sign to be able to represent a negative value:

    (ISO8601::Duration.new('PT10S') - ISO8601::Duration.new('PT12S')).to_s #=> '-PT2S'
    (ISO8601::Duration.new('-PT10S') + ISO8601::Duration.new('PT12S')).to_s #=> 'PT2S'

### Separators

Although, the spec allows three separator types: period (.), comma (,), and raised period (·) by now I keep just the period option.

### Century treatment

The specification says that you can express a reduced precision year
just giving the century (i.e. '20' to refer the inclusive range 2000-2999).

This implementation expands the century to the first value for its range
so:

    ISO8601::DateTime.new('20').century # => 20
    ISO8601::DateTime.new('20').year # => 2000


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

