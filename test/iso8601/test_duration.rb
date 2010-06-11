require "test/unit"
require "iso8601"


class TestDuration < Test::Unit::TestCase
  def test_patterns
    assert_raise(ISO8601::Errors::UnknownPattern) { ISO8601::Duration.new("P") }
    assert_nothing_raised() { ISO8601::Duration.new("P1Y") }
    assert_nothing_raised() { ISO8601::Duration.new("P1Y1M") }
    assert_nothing_raised() { ISO8601::Duration.new("P1Y1M1D") }
    assert_raise(ISO8601::Errors::UnknownPattern) { ISO8601::Duration.new("P1Y1M1DT") }
    assert_nothing_raised() { ISO8601::Duration.new("P1Y1M1DT1H") }
    assert_nothing_raised() { ISO8601::Duration.new("P1Y1M1DT1H1M") }
    assert_nothing_raised() { ISO8601::Duration.new("P1Y1M1DT1H1M1S") }
    assert_raise(ISO8601::Errors::UnknownPattern) { ISO8601::Duration.new("PT") }
    assert_nothing_raised() { ISO8601::Duration.new("PT1H") }
    assert_nothing_raised() { ISO8601::Duration.new("PT1H1M") }
    assert_nothing_raised() { ISO8601::Duration.new("PT1H1S") }
    assert_nothing_raised() { ISO8601::Duration.new("PT1H1M1S") }
    assert_nothing_raised() { ISO8601::Duration.new("+PT1H1M1S") }
    assert_nothing_raised() { ISO8601::Duration.new("-PT1H1M1S") }
    assert_raise(ISO8601::Errors::UnknownPattern) { ISO8601::Duration.new("~PT1H1M1S") }
    assert_raise(ISO8601::Errors::UnknownPattern) { ISO8601::Duration.new("T") }
  end
  def test_base
    assert_nothing_raised() { ISO8601::Duration.new("P1Y1M1DT1H1M1S", ISO8601::DateTime.new("2010-01-01")) }
    assert_raise(TypeError) { ISO8601::Duration.new("P1Y1M1DT1H1M1S", "2010-01-01") }
    assert_raise(TypeError) { ISO8601::Duration.new("P1Y1M1DT1H1M1S", 2010) }
    assert_instance_of(ISO8601::DateTime, ISO8601::Duration.new("P1Y1M1DT1H1M1S", ISO8601::DateTime.new("2010-01-01")).base)
    assert_instance_of(NilClass, ISO8601::Duration.new("P1Y1M1DT1H1M1S").base)
    assert_instance_of(ISO8601::DateTime, (ISO8601::Duration.new("P1Y1M1DT1H1M1S").base = ISO8601::DateTime.new("2010-01-01")))
  end
  def test_addition
    assert_equal("P1YT2M24S", (ISO8601::Duration.new("P1YT2M12S") + ISO8601::Duration.new("PT12S")).to_s, "d1 + d2")
    assert_instance_of(ISO8601::Duration, ISO8601::Duration.new("P1YT2M12S") + ISO8601::Duration.new("PT12S"))
  end
  def test_substraction
    assert_equal("P1YT2M", (ISO8601::Duration.new("P1YT2M12S") - ISO8601::Duration.new("PT12S")).to_s, "d1 - d2 > 0")
    assert_equal("PT0S", (ISO8601::Duration.new("PT12S") - ISO8601::Duration.new("PT12S")).to_s, "d1 - d2 = 0")
    assert_equal("-P1YT1M", (ISO8601::Duration.new("PT12S") - ISO8601::Duration.new("P1YT1M12S")).to_s, "d1 - d2 < 0")
    assert_instance_of(ISO8601::Duration, ISO8601::Duration.new("P1YT2M12S") - ISO8601::Duration.new("PT12S"))
  end
  def test_abs
    assert_equal("P1YT2M", ISO8601::Duration.new("-P1YT2M").abs)
    assert_equal("P1YT1M", (ISO8601::Duration.new("PT12S") - ISO8601::Duration.new("P1YT1M12S")).abs)
  end
  def test_date_to_seconds
    assert_equal(63072000, ISO8601::Duration.new("P2Y").to_seconds, "P[n]Y form")
    assert_equal(63158400, ISO8601::Duration.new("P2Y", ISO8601::DateTime.new("2000-01-01")).to_seconds, "P[n]Y form in leap year")
    assert_equal(70956000, ISO8601::Duration.new("P2Y3M").to_seconds, "P[n]Y[n]M form")
    assert_equal(70934400, ISO8601::Duration.new("P2Y3M", ISO8601::DateTime.new("2000-01-01")).to_seconds, "P[n]Y[n]M form in leap year")
    assert_equal(71107200, ISO8601::Duration.new("P2Y3M", ISO8601::DateTime.new("2000-06-01")).to_seconds, "P[n]Y[n]M form in leap year")
    assert_equal(65577600, ISO8601::Duration.new("P1Y13M", ISO8601::DateTime.new("2010-02-01")).to_seconds, "P[n]Y[n]M form with months > 12")
    assert_equal(ISO8601::Duration.new("P2Y1M", ISO8601::DateTime.new("2010-02-01")).to_seconds, ISO8601::Duration.new("P1Y13M", ISO8601::DateTime.new("2010-02-01")).to_seconds)
    assert_equal(Time.utc(2001, 4) - Time.utc(2000, 2), ISO8601::Duration.new("P14M", ISO8601::DateTime.new("2000-02-01")).to_seconds)

    assert_equal(64022400, ISO8601::Duration.new("P2Y11D").to_seconds, "P[n]Y[n]D form")
    assert_equal(71906400, ISO8601::Duration.new("P2Y3M11D").to_seconds, "P[n]Y[n]M[n]D form")
    assert_equal(7884000, ISO8601::Duration.new("P3M").to_seconds, "P[n]M form")
    assert_equal(8834400, ISO8601::Duration.new("P3M11D").to_seconds, "P[n]M[n]D form")
    assert_equal(950400, ISO8601::Duration.new("P11D").to_seconds, "P[n]D form")
  end

  def test_time_to_seconds
    assert_equal(18000, ISO8601::Duration.new("PT5H").to_seconds, "PT[n]H form")
    assert_equal(26400, ISO8601::Duration.new("PT7H20M").to_seconds, "PT[n]H[n]M form")
    assert_equal(144034, ISO8601::Duration.new("PT40H34S").to_seconds, "PT[n]H[n]S form")
    assert_equal(27003, ISO8601::Duration.new("PT7H30M3S").to_seconds, "PT[n]H[n]M[n]S form")
    assert_equal(2040, ISO8601::Duration.new("PT34M").to_seconds, "PT[n]M form")
    assert_equal(2050, ISO8601::Duration.new("PT34M10S").to_seconds, "PT[n]M[n]S form")
    assert_equal(10, ISO8601::Duration.new("PT10S").to_seconds, "PT[n]S form")
    assert_equal(ISO8601::Duration.new("PT1H15M").to_seconds, ISO8601::Duration.new("PT75M").to_seconds, "PT[n]H[n]M equivalent to PT[n]M")
  end

  def test_dateTime_to_seconds
    assert_equal(71965843, ISO8601::Duration.new("P2Y3M11DT16H30M43S").to_seconds, "P[n]Y[n]M[n]DT[n]H[n]M[n]S form")
    assert_equal(71965800, ISO8601::Duration.new("P2Y3M11DT16H30M").to_seconds, "P[n]Y[n]M[n]DT[n]H[n]M form")
    assert_equal(71964000, ISO8601::Duration.new("P2Y3M11DT16H").to_seconds, "P[n]Y[n]M[n]DT[n]H form")
    assert_equal(71964043, ISO8601::Duration.new("P2Y3M11DT16H43S").to_seconds, "P[n]Y[n]M[n]DT[n]H[n]S form")
    assert_equal(71908243, ISO8601::Duration.new("P2Y3M11DT30M43S").to_seconds, "P[n]Y[n]M[n]DT[n]M[n]S form")
    assert_equal(71908200, ISO8601::Duration.new("P2Y3M11DT30M").to_seconds, "P[n]Y[n]M[n]DT[n]M form")
    assert_equal(71906443, ISO8601::Duration.new("P2Y3M11DT43S").to_seconds, "P[n]Y[n]M[n]DT[n]S form")
    assert_equal(ISO8601::Duration.new("P1DT12H").to_seconds, ISO8601::Duration.new("PT36H").to_seconds, "P[n]DT[n]H equivalent to PT[n]H")
  end
end