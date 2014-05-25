# encoding: utf-8

require 'spec_helper'

describe ISO8601::Duration do
  it "should raise a ISO8601::Errors::UnknownPattern for any unknown pattern" do
    expect { ISO8601::Duration.new('P') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('PT') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('P1YT') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('T') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('PW') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('P1Y1W') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('~P1Y') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('.P1Y') }.to raise_error(ISO8601::Errors::UnknownPattern)
  end
  it "should parse any allowed pattern" do
    expect { ISO8601::Duration.new('P1Y') }.to_not raise_error
    expect { ISO8601::Duration.new('P1Y1M') }.to_not raise_error
    expect { ISO8601::Duration.new('P1Y1M1D') }.to_not raise_error
    expect { ISO8601::Duration.new('P1Y1M1DT1H') }.to_not raise_error
    expect { ISO8601::Duration.new('P1Y1M1DT1H1M') }.to_not raise_error
    expect { ISO8601::Duration.new('P1Y1M1DT1H1M1S') }.to_not raise_error
    expect { ISO8601::Duration.new('P1Y1M1DT1H1M1.0S') }.to_not raise_error
    expect { ISO8601::Duration.new('P1W') }.to_not raise_error
    expect { ISO8601::Duration.new('+P1Y') }.to_not raise_error
    expect { ISO8601::Duration.new('-P1Y') }.to_not raise_error
  end
  it "should raise a TypeError when the base is not a ISO8601::DateTime" do
    expect { ISO8601::Duration.new('P1Y1M1DT1H1M1S', ISO8601::DateTime.new('2010-01-01')) }.to_not raise_error
    expect { ISO8601::Duration.new('P1Y1M1DT1H1M1S', '2010-01-01') }.to raise_error(TypeError)
    expect { ISO8601::Duration.new('P1Y1M1DT1H1M1S', 2010) }.to raise_error(TypeError)
    expect {
      d = ISO8601::Duration.new('P1Y1M1DT1H1M1S', ISO8601::DateTime.new('2010-01-01'))
      d.base = 2012
    }.to raise_error(TypeError)
  end

  it "should return a Duration instance from a Numeric input" do
    ISO8601::Duration.new(36993906, ISO8601::DateTime.new('2012-01-01')).should == ISO8601::Duration.new('P1Y2M3DT4H5M6S', ISO8601::DateTime.new('2012-01-01'))
  end

  describe '#base' do
    it "should return the base datetime" do
      dt = ISO8601::DateTime.new('2010-01-01')
      dt2 = ISO8601::DateTime.new('2012-01-01')
      ISO8601::Duration.new('P1Y1M1DT1H1M1S').base.should be_an_instance_of(NilClass)
      ISO8601::Duration.new('P1Y1M1DT1H1M1S', dt).base.should be_an_instance_of(ISO8601::DateTime)
      ISO8601::Duration.new('P1Y1M1DT1H1M1S', dt).base.should equal(dt)
      d = ISO8601::Duration.new('P1Y1M1DT1H1M1S', dt).base = dt2
      d.should equal(dt2)
    end
  end

  describe '#to_s' do
    it "should return the duration as a string" do
      ISO8601::Duration.new('P1Y1M1DT1H1M1S').to_s.should == 'P1Y1M1DT1H1M1S'
    end
  end

  describe '#+' do
    it "should raise an ISO8601::Errors::DurationBaseError" do
      expect { ISO8601::Duration.new('PT1H', ISO8601::DateTime.new('2000-01-01')) + ISO8601::Duration.new('PT1H') }.to raise_error(ISO8601::Errors::DurationBaseError)
    end

    it "should return the result of the addition" do
      (ISO8601::Duration.new('P1Y1M1DT1H1M1S') + ISO8601::Duration.new('PT10S')).to_s.should == 'P1Y1M1DT1H1M11S'
      (ISO8601::Duration.new('P1Y1M1DT1H1M1S') + ISO8601::Duration.new('PT10S')).should be_an_instance_of(ISO8601::Duration)
    end
  end

  describe '#-' do
    it "should raise an ISO8601::Errors::DurationBaseError" do
      expect { ISO8601::Duration.new('PT1H', ISO8601::DateTime.new('2000-01-01')) - ISO8601::Duration.new('PT1H') }.to raise_error(ISO8601::Errors::DurationBaseError)
    end

    it "should return the result of the substraction" do
      (ISO8601::Duration.new('P1Y1M1DT1H1M1S') - ISO8601::Duration.new('PT10S')).should be_an_instance_of(ISO8601::Duration)
      (ISO8601::Duration.new('P1Y1M1DT1H1M11S') - ISO8601::Duration.new('PT10S')).to_s.should == 'P1Y1M1DT1H1M1S'
      (ISO8601::Duration.new('PT12S') - ISO8601::Duration.new('PT12S')).to_s.should == 'PT0S'
      (ISO8601::Duration.new('PT12S') - ISO8601::Duration.new('PT1S')).to_s.should == 'PT11S'
      (ISO8601::Duration.new('PT1S') - ISO8601::Duration.new('PT12S')).to_s.should == '-PT11S'
      (ISO8601::Duration.new('PT1S') - ISO8601::Duration.new('-PT12S')).to_s.should == 'PT13S'
    end
  end

  describe '#to_seconds' do
    it "should return the seconds of a P[n]Y duration in a common year" do
      ISO8601::Duration.new('P2Y', ISO8601::DateTime.new('2010-01-01')).to_seconds.should == (Time.utc(2012, 1) - Time.utc(2010, 1))
    end
    it "should return the seconds of a P[n]Y duration in a leap year" do
      ISO8601::Duration.new('P2Y', ISO8601::DateTime.new('2000-01-01')).to_seconds.should == (Time.utc(2002, 1) - Time.utc(2000, 1))
    end
    it "should return the seconds of a P[n]Y[n]M duration in a common year" do
      ISO8601::Duration.new('P2Y3M', ISO8601::DateTime.new('2010-01-01')).to_seconds.should == (Time.utc(2012, 4) - Time.utc(2010, 1))
    end
    it "should return the seconds of a P[n]Y[n]M duration in a leap year" do
      ISO8601::Duration.new('P2Y3M', ISO8601::DateTime.new('2000-01-01')).to_seconds.should == (Time.utc(2002, 4) - Time.utc(2000, 1))
    end
    it "should return the seconds of a P[n]M duration in a common year" do
      ISO8601::Duration.new('P1M', ISO8601::DateTime.new('2012-01-01')).to_seconds.should == (Time.utc(2012, 2) - Time.utc(2012, 1))
      ISO8601::Duration.new('P2M', ISO8601::DateTime.new('2012-01-01')).to_seconds.should == (Time.utc(2012, 3) - Time.utc(2012, 1))
      ISO8601::Duration.new('P14M', ISO8601::DateTime.new('2012-01-01')).to_seconds.should == (Time.utc(2013, 3) - Time.utc(2012, 1))
    end
    it "should return the seconds of a P[n]M duration in a leap year" do
      ISO8601::Duration.new('P1M', ISO8601::DateTime.new('2000-01-01')).to_seconds.should == (Time.utc(2000, 2) - Time.utc(2000, 1))
      ISO8601::Duration.new('P2M', ISO8601::DateTime.new('2000-01-01')).to_seconds.should == (Time.utc(2000, 3) - Time.utc(2000, 1))
      ISO8601::Duration.new('P14M', ISO8601::DateTime.new('2000-01-01')).to_seconds.should == (Time.utc(2001, 3) - Time.utc(2000, 1))
    end
    it "should return the seconds of a P[n]Y[n]M[n]D duration" do
      ISO8601::Duration.new('P2Y11D', ISO8601::DateTime.new('2012-01-01')).to_seconds.should == (Time.utc(2014, 1, 12) - Time.utc(2012, 1))
      ISO8601::Duration.new('P1Y1M1D', ISO8601::DateTime.new('2010-05-01')).to_seconds.should == (Time.utc(2011, 6, 2) - Time.utc(2010, 5))
    end
    it "should return the seconds of a P[n]D duration" do
      ISO8601::Duration.new('P1D', ISO8601::DateTime.new('2012-01-01')).to_seconds.should == (Time.utc(2012, 1, 2) - Time.utc(2012, 1, 1))
      ISO8601::Duration.new('P11D', ISO8601::DateTime.new('2012-01-01')).to_seconds.should == (Time.utc(2012, 1, 12) - Time.utc(2012, 1, 1))
      ISO8601::Duration.new('P3M11D', ISO8601::DateTime.new('2012-01-01')).to_seconds.should == (Time.utc(2012, 4, 12) - Time.utc(2012, 1))
    end
    it "should return the seconds of a P[n]W duration" do
      ISO8601::Duration.new('P2W', ISO8601::DateTime.new('2012-01-01')).to_seconds.should == (Time.utc(2012, 1, 15) - Time.utc(2012, 1))
      ISO8601::Duration.new('P2W', ISO8601::DateTime.new('2012-02-01')).to_seconds.should == (Time.utc(2012, 2, 15) - Time.utc(2012, 2))
    end

    it "should return the seconds of a PT[n]H duration" do
      ISO8601::Duration.new('PT5H', ISO8601::DateTime.new('2012-01-01')).to_seconds.should == (Time.utc(2012, 1, 1, 5) - Time.utc(2012, 1))
      ISO8601::Duration.new('P1YT5H', ISO8601::DateTime.new('2012-01-01')).to_seconds.should == (Time.utc(2013, 1, 1, 5) - Time.utc(2012, 1))
    end

    it "should return the seconds of a PT[n]H[n]M duration" do
      ISO8601::Duration.new('PT5M', ISO8601::DateTime.new('2012-01-01')).to_seconds.should == (Time.utc(2012, 1, 1, 0, 5) - Time.utc(2012, 1))
      ISO8601::Duration.new('PT1H5M', ISO8601::DateTime.new('2012-01-01')).to_seconds.should == (Time.utc(2012, 1, 1, 1, 5) - Time.utc(2012, 1))
      ISO8601::Duration.new('PT1H5M', ISO8601::DateTime.new('2012-01-01')).to_seconds.should == ISO8601::Duration.new('PT65M', ISO8601::DateTime.new('2012-01-01')).to_seconds
    end

    it "should return the seconds of a PT[n]H[n]M duration" do
      ISO8601::Duration.new('PT10S', ISO8601::DateTime.new('2012-01-01')).to_seconds.should == (Time.utc(2012, 1, 1, 0, 0, 10) - Time.utc(2012, 1))
      ISO8601::Duration.new('PT10.4S', ISO8601::DateTime.new('2012-01-01')).to_seconds.should == 10.4
    end

  end

  describe '#==' do
    it "should raise an ISO8601::Errors::DurationBaseError" do
      expect { ISO8601::Duration.new('PT1H', ISO8601::DateTime.new('2000-01-01')) == ISO8601::Duration.new('PT1H') }.to raise_error(ISO8601::Errors::DurationBaseError)
    end
    it "should return True" do
      ISO8601::Duration.new('PT1H').should == ISO8601::Duration.new('PT1H')
    end
  end

  describe '#to_abs' do
    it "should return a kind of duration" do
      ISO8601::Duration.new('-PT1H').abs.should be_an_instance_of ISO8601::Duration
    end
    it "should return the absolute value of the duration" do
      ISO8601::Duration.new('-PT1H').abs.should == ISO8601::Duration.new('PT1H')
      (ISO8601::Duration.new('PT1H') - ISO8601::Duration.new('PT2H')).abs.should == ISO8601::Duration.new('PT1H')
      (ISO8601::Duration.new('PT1H') - ISO8601::Duration.new('-PT2H')).abs.should == ISO8601::Duration.new('PT3H')
    end
  end

end
