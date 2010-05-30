require "test/unit"
require "iso8601"

class TestDateTime < Test::Unit::TestCase
  def test_patterns
    assert_raise(ISO8601::Errors::UnknownPattern) { ISO8601::DateTime.new("2") }
    assert_raise(ISO8601::Errors::UnknownPattern) { ISO8601::DateTime.new("201") }
    assert_raise(ISO8601::Errors::UnknownPattern) { ISO8601::DateTime.new("2010-") }
    assert_raise(ISO8601::Errors::UnknownPattern) { ISO8601::DateTime.new("20-05") }
    assert_raise(ISO8601::Errors::UnknownPattern) { ISO8601::DateTime.new("2010-0") }
    assert_raise(ISO8601::Errors::UnknownPattern) { ISO8601::DateTime.new("2010-0-09") }
    assert_raise(ISO8601::Errors::UnknownPattern) { ISO8601::DateTime.new("2010-1-09") }
    assert_raise(ISO8601::Errors::UnknownPattern) { ISO8601::DateTime.new("2010-1-09") }
    assert_raise(ISO8601::Errors::UnknownPattern) { ISO8601::DateTime.new("20101-09") }
    assert_raise(ISO8601::Errors::UnknownPattern) { ISO8601::DateTime.new("201-0109") }
    assert_raise(ISO8601::Errors::UnknownPattern) { ISO8601::DateTime.new("2010-05-09T103012+0400") }
    assert_raise(ISO8601::Errors::UnknownPattern) { ISO8601::DateTime.new("20100509T10:30:12+04:00") }
    assert_raise(ISO8601::Errors::UnknownPattern) { ISO8601::DateTime.new("2010-05-09T10:30:12+0400") }
    assert_raise(ISO8601::Errors::UnknownPattern) { ISO8601::DateTime.new("2010-05-09T10:3012+0400") }
    assert_raise(ISO8601::Errors::UnknownPattern) { ISO8601::DateTime.new("2010-05-09T10:3012") }
    assert_raise(ISO8601::Errors::UnknownPattern) { ISO8601::DateTime.new("2010:05:09T10:30:12+04:00") }

    assert_raise(RangeError) { ISO8601::DateTime.new("2010-01-32") }
    assert_raise(RangeError) { ISO8601::DateTime.new("2010-02-31") }
    assert_raise(RangeError) { ISO8601::DateTime.new("2010-13-31") }
    
    assert_nothing_raised() { ISO8601::DateTime.new("20") }
    assert_nothing_raised() { ISO8601::DateTime.new("2010") }
    assert_nothing_raised() { ISO8601::DateTime.new("2010-05") }
    assert_nothing_raised() { ISO8601::DateTime.new("2010-05-09") }
    assert_nothing_raised() { ISO8601::DateTime.new("2010-05-09") }
    assert_nothing_raised() { ISO8601::DateTime.new("2010-05-09T10") }
    assert_nothing_raised() { ISO8601::DateTime.new("2010-05-09T10:30") }
    assert_nothing_raised() { ISO8601::DateTime.new("2010-05-09T10:30:12") }
    assert_nothing_raised() { ISO8601::DateTime.new("2010-05-09T10:30:12Z") }
    assert_nothing_raised() { ISO8601::DateTime.new("2010-05-09T10:30:12+04:00") }
    assert_nothing_raised() { ISO8601::DateTime.new("2010-05-09T10:30:12-04:00") }
    assert_nothing_raised() { ISO8601::DateTime.new("2010-05-09T10:30:12+04") }
    assert_nothing_raised() { ISO8601::DateTime.new("201005") }
    assert_nothing_raised() { ISO8601::DateTime.new("20100509") }
    assert_nothing_raised() { ISO8601::DateTime.new("20100509T103012") }
    assert_nothing_raised() { ISO8601::DateTime.new("20100509T103012Z") }
    assert_nothing_raised() { ISO8601::DateTime.new("20100509T103012+0400") }
    assert_nothing_raised() { ISO8601::DateTime.new("20100509T103012-0400") }
    assert_nothing_raised() { ISO8601::DateTime.new("20100509T103012+04") }
  end
  
  def test_atom_methods
    assert_equal(20, ISO8601::DateTime.new("2010-05-09").century)
    assert_equal(2010, ISO8601::DateTime.new("2010-05-09").year)
    assert_equal(5, ISO8601::DateTime.new("2010-05-09").month)
    assert_equal(9, ISO8601::DateTime.new("2010-05-09").day)
  end
  
  def test_to_time
    assert_instance_of(Time, ISO8601::DateTime.new("2010-05-09").to_time)
  end
end