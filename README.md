# ISO8601

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/arnau/ISO8601?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

ISO8601 is a simple implementation of the ISO 8601 (Data elements and
interchange formats — Information interchange — Representation of dates and
times) standard.

## Build status

[![Build Status](https://secure.travis-ci.org/arnau/ISO8601.png?branch=master)](http://travis-ci.org/arnau/ISO8601/)
[![Dependency Status](https://gemnasium.com/arnau/ISO8601.svg)](https://gemnasium.com/arnau/ISO8601)
[![Gem Version](https://badge.fury.io/rb/iso8601.svg)](http://badge.fury.io/rb/iso8601)

## Supported versions

* MRI 1.9.3, 2.0, 2.1, 2.2
* RBX 2

Check the [changelog](https://github.com/arnau/ISO8601/blob/master/CHANGELOG.md) if you are upgrading from an older version.

## Documentation

Check the [rubydoc documentation](http://www.rubydoc.info/gems/iso8601).

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


## Testing

### Raw

    # Install a Ruby flavour
    $ bundle install
    $ bundle exec rspec

### Docker (experimental)

This way is in an early stage so for now it's only possible to test one Ruby
version (currently Ruby 2.2.)

    # Install Docker
    $ make build
    $ make run

### Vagrant (experimental)

This way is in an early stage so for now it's only possible to test one Ruby
version (currently Ruby 2.2.)

    # Install Vagrant and Virtualbox
    $ vagrant up mri-2.2


## Contributing

[Contributors](https://github.com/arnau/ISO8601/graphs/contributors)

1. Fork it (http://github.com/arnau/ISO8601/fork)
2. Create your feature branch (git checkout -b features/xyz)
3. Commit your changes (git commit -am 'Add XYZ')
4. Push to the branch (git push origin features/xyz)
5. Create new Pull Request


## License

Arnau Siches under the [MIT License](https://github.com/arnau/ISO8601/blob/master/LICENSE)
