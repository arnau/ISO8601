# ISO8601

Version 0.9.0 is **not compatible** with previous versions.  Atoms and Durations
changed their interface when treating base dates so it is only applied when
computing the Atom length (e.g. `#to_seconds`).  As a consequence, it is no
longer possible to do operations like `DateTime + Duration`.

Version 1.0.0 will lock public interfaces.

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

Check the [rubydoc documentation](http://www.rubydoc.info/gems/iso8601). Or
take a look to the implementation notes:

* [Date, Time, DateTime](docs/date-time.md)
* [Duration](docs/duration.md)
* [Time interval](docs/time-interval.md)


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
