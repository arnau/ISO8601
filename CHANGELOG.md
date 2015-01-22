## 0.8.4

* Remove unwanted log.

## 0.8.3

* Fix partial time patterns with timezone: `PThh:mmZ`, `PThhZ`.

## 0.8.2

* Fix time components using comma (,) as a decimal separator.

## 0.8.1

* Fix durations using comma (,) as a decimal separator.

## 0.8.0

* `DateTime` has hash identity by value.
* `Time` has hash identity by value.
* `Date` has hash identity by value.
* `Duration` has hash identity by value.
* `Atom` has hash identity by value.
* `Atom#value` returns either an integer or a float.
* `Atom#to_s` returns a valid ISO8601 subpattern.

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
