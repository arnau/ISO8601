require "test/unit"
require "iso8601"


class TestAtom < Test::Unit::TestCase
  def test_arguments
    assert_raise(TypeError) { ISO8601::Atom.new("1") }
    assert_raise(TypeError) { ISO8601::Atom.new(1.0) }
    assert_raise(TypeError) { ISO8601::Atom.new(true) }
    assert_nothing_raised() { ISO8601::Atom.new(-1) }
    assert_nothing_raised() { ISO8601::Atom.new(0) }
    assert_nothing_raised() { ISO8601::Atom.new(1) }
  end
end
class TestYears < Test::Unit::TestCase
  def test_factor
    assert_equal(31536000, ISO8601::Years.new(2).factor)
    assert_equal(31536000, ISO8601::Years.new(1, ISO8601::DateTime.new("2010-01-01")).factor, "common year")
    assert_equal(31622400, ISO8601::Years.new(1, ISO8601::DateTime.new("2000-01-01")).factor, "leap year")
  end
  def test_to_seconds
    assert_equal(63072000, ISO8601::Years.new(2).to_seconds)
    assert_equal(-63072000, ISO8601::Years.new(-2).to_seconds)
    assert_equal(63072000, ISO8601::Years.new(2, ISO8601::DateTime.new("2010-01-01")).to_seconds, "common year")
    assert_equal(63244800, ISO8601::Years.new(2, ISO8601::DateTime.new("2000-01-01")).to_seconds, "leap year")
  end
end
class TestMonths < Test::Unit::TestCase
  def test_factor
    assert_equal(2628000, ISO8601::Months.new(2).factor)
    assert_equal(2628000, ISO8601::Months.new(1, ISO8601::DateTime.new("2010-01-01")).factor, "common year")
    assert_equal(2635200, ISO8601::Months.new(1, ISO8601::DateTime.new("2000-01-01")).factor, "leap year")
  end
  def test_to_seconds
    assert_equal(5256000, ISO8601::Months.new(2).to_seconds)
    assert_equal(-5256000, ISO8601::Months.new(-2).to_seconds)
    assert_equal(5256000, ISO8601::Months.new(2, ISO8601::DateTime.new("2010-01-01")).to_seconds, "common year")
    assert_equal(5270400, ISO8601::Months.new(2, ISO8601::DateTime.new("2000-01-01")).to_seconds, "leap year")
  end
end
class TestDays < Test::Unit::TestCase
  def test_factor
    assert_equal(86400, ISO8601::Days.new(2).factor)
  end
  def test_to_seconds
    assert_equal(172800, ISO8601::Days.new(2).to_seconds)
    assert_equal(-172800, ISO8601::Days.new(-2).to_seconds)
  end
end
class TestHours < Test::Unit::TestCase
  def test_factor
    assert_equal(3600, ISO8601::Hours.new(2).factor)
  end
  def test_to_seconds
    assert_equal(7200, ISO8601::Hours.new(2).to_seconds)
    assert_equal(-7200, ISO8601::Hours.new(-2).to_seconds)
  end
end
class TestMinutes < Test::Unit::TestCase
  def test_factor
    assert_equal(60, ISO8601::Minutes.new(2).factor)
  end
  def test_to_seconds
    assert_equal(120, ISO8601::Minutes.new(2).to_seconds)
    assert_equal(-120, ISO8601::Minutes.new(-2).to_seconds)
  end
end
class TestSeconds < Test::Unit::TestCase
  def test_factor
    assert_equal(1, ISO8601::Seconds.new(2).factor)
  end
  def test_to_seconds
    assert_equal(2, ISO8601::Seconds.new(2).to_seconds)
    assert_equal(-2, ISO8601::Seconds.new(-2).to_seconds)
  end
end


