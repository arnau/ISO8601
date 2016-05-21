## 0.9.1

* Fix `Duration#to_pattern` for negative durations based on a `Numeric` (thanks @figwit).

## 0.9.0

This version is **not compatible** with previous versions.  Atoms and Durations
changed their interface when treating base dates so it is only applied when
computing the Atom length (e.g. `#to_seconds`).  As a consequence, it is no
longer possible to do operations like `DateTime + Duration`.

* Add time intervals (thanks @Angelmmiguel).
* Remove `Duration#to_i`.
* Change `Duration#to_seconds` to accept a base `DateTime`.
* Remove duration dependency on a base date on the instance level.
* Change `Years#to_seconds` and `Months#to_seconds` to accept a base `DateTime`.
* Remove atom dependency on a base date on the instance level.
* Add `Atomic` mixin.
* Remove `Atom` abstract class.
* Allow `ISO8601::Duration` to perform operations with `Numeric` (thanks @Angelmmiguel).

## 0.8.7

* Make `Atom` comparable with the same kind (thanks @glassbead0).
* Fix #18 document interfaces to core date/time classes.

## 0.8.6

* Fix #26 operations with Date, DateTime and Time with Duration (e.g. `ISO8601::DateTime.new('2012-07-07T20:20:20Z') - ISO8601::Duration.new('PT10M')`).
* Fix #25 accept time components with timezone and only hour component (e.g. `ISO8601::Time.new('T10+01:00')`).
* Fix Docker image for testing and inspecting.

## 0.8.5

* Fix `DateTime#hash`
* Fix `DateTime#second` and `Time#second` precision.  Now it's rounded to the
first decimal.

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
