## 0.7.1

* Atoms have hash identity by value.
* Atoms have `#value` to get either an integer or a float.
* Atoms have `#to_s` formatting to a valid ISO8601 subpattern.

## 0.7.0

* Add decimal fractions for any component in a duration.
* Add a catch all `ISO8601::Errors::StandardError`.
* Add support for comma (`,`) as a separator for duration decimal fractions.

## 0.6.0

* Add `#hash` to `Duration`, `Date`, `Time` and `DateTime`.

## 0.5.2

* Fix `DateTime` when handling empty strings.

## 0.5.1

* Fix durations with sign.

## 0.5.0

* Drop support for Ruby 1.8.7.
* Add support for Rubinius 2.
* `ISO8601::DateTime#century` no longer exists. Truncated representations were
removed in ISO 8601:2004.
* `ISO8601::DateTime#zone` delegates to core `DateTime#zone`.
* `ISO8601::DateTime#timezone` no longer exists. Now it delegates to
`DateTime#zone`.
* A date can have sign: `-1000-01-01`, `+2014-05-06T10:11:12Z`.
* A date time can be converted to an array of atoms with `#to_a`.
* Ordinal dates supported.
* A date component is represented by `ISO8601::Date`.
* Week date pattern (YYYY-Wdww, YYYY-Www-D).
