# encoding: utf-8

require 'spec_helper'

RSpec.describe ISO8601::Duration do
  let(:common_year) { ISO8601::DateTime.new('2010-01-01') }
  let(:leap_year) { ISO8601::DateTime.new('2000-01-01') }

  let(:common_february) { ISO8601::DateTime.new('2010-02-01') }
  let(:leap_february) { ISO8601::DateTime.new('2000-02-01') }

  it "should raise a ISO8601::Errors::UnknownPattern for any unknown pattern" do
    expect { ISO8601::Duration.new('') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('P') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('PT') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('P1YT') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('T') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('PW') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('P1Y1W') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('~P1Y') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('.P1Y') }.to raise_error(ISO8601::Errors::UnknownPattern)
  end

  it "should raise a ISO8601::Errors::InvalidFraction for any invalid patterns" do
    expect { ISO8601::Duration.new('P1.5Y0.5M') }.to raise_error(ISO8601::Errors::InvalidFractions)
    expect { ISO8601::Duration.new('P1.5Y1M') }.to raise_error(ISO8601::Errors::InvalidFractions)
    expect { ISO8601::Duration.new('P1.5MT10.5S') }.to raise_error(ISO8601::Errors::InvalidFractions)
  end

  it "should parse any allowed pattern" do
    expect { ISO8601::Duration.new('P1Y') }.to_not raise_error
    expect { ISO8601::Duration.new('P0.5Y') }.to_not raise_error
    expect { ISO8601::Duration.new('P0,5Y') }.to_not raise_error
    expect { ISO8601::Duration.new('P1Y1M') }.to_not raise_error
    expect { ISO8601::Duration.new('P1Y0.5M') }.to_not raise_error
    expect { ISO8601::Duration.new('P1Y0,5M') }.to_not raise_error
    expect { ISO8601::Duration.new('P1Y1M1D') }.to_not raise_error
    expect { ISO8601::Duration.new('P1Y1M0.5D') }.to_not raise_error
    expect { ISO8601::Duration.new('P1Y1M0,5D') }.to_not raise_error
    expect { ISO8601::Duration.new('P1Y1M1DT1H') }.to_not raise_error
    expect { ISO8601::Duration.new('P1Y1M1DT0.5H') }.to_not raise_error
    expect { ISO8601::Duration.new('P1Y1M1DT0,5H') }.to_not raise_error
    expect { ISO8601::Duration.new('P1Y1M1DT1H1M') }.to_not raise_error
    expect { ISO8601::Duration.new('P1Y1M1DT1H0.5M') }.to_not raise_error
    expect { ISO8601::Duration.new('P1Y1M1DT1H0,5M') }.to_not raise_error
    expect { ISO8601::Duration.new('P1Y1M1DT1H1M1S') }.to_not raise_error
    expect { ISO8601::Duration.new('P1Y1M1DT1H1M1.0S') }.to_not raise_error
    expect { ISO8601::Duration.new('P1Y1M1DT1H1M1,0S') }.to_not raise_error
    expect { ISO8601::Duration.new('P1W') }.to_not raise_error
    expect { ISO8601::Duration.new('+P1Y') }.to_not raise_error
    expect { ISO8601::Duration.new('-P1Y') }.to_not raise_error
  end

  it "should raise a TypeError when the base is not a ISO8601::DateTime" do
    expect { ISO8601::Duration.new('P1Y1M1DT1H1M1S', common_year) }.to_not raise_error
    expect { ISO8601::Duration.new('P1Y1M1DT1H1M1S', '2010-01-01') }.to raise_error(ISO8601::Errors::TypeError)
    expect { ISO8601::Duration.new('P1Y1M1DT1H1M1S', 2010) }.to raise_error(ISO8601::Errors::TypeError)
    expect do
      d = ISO8601::Duration.new('P1Y1M1DT1H1M1S', common_year)
      d.base = 2012
    end.to raise_error(ISO8601::Errors::TypeError)
  end

  it "should return a Duration instance from a Numeric input" do
    expect(ISO8601::Duration.new(36993906, common_year).to_seconds).to eq(36993906)
  end

  describe '#base' do
    it "should return the base datetime" do
      dt2 = ISO8601::DateTime.new('2012-01-01')
      expect(ISO8601::Duration.new('P1Y1M1DT1H1M1S').base).to be_an_instance_of(NilClass)
      expect(ISO8601::Duration.new('P1Y1M1DT1H1M1S', common_year).base).to be_an_instance_of(ISO8601::DateTime)
      expect(ISO8601::Duration.new('P1Y1M1DT1H1M1S', common_year).base).to eq(common_year)
      d = ISO8601::Duration.new('P1Y1M1DT1H1M1S', common_year).base = dt2
      expect(d).to eq(dt2)
    end
  end

  describe '#pattern' do
    it "should return the duration pattern" do
      expect(ISO8601::Duration.new('P1Y1M1DT1H1M1S').pattern).to eq('P1Y1M1DT1H1M1S')
      expect(ISO8601::Duration.new(60).pattern).to eq('PT60S')
    end
  end

  describe '#to_s' do
    it "should return the duration as a string" do
      expect(ISO8601::Duration.new('P1Y1M1DT1H1M1S').to_s).to eq('P1Y1M1DT1H1M1S')
    end
  end

  describe '#+' do
    it "should raise an ISO8601::Errors::DurationBaseError" do
      expect { ISO8601::Duration.new('PT1H', leap_year) + ISO8601::Duration.new('PT1H') }.to raise_error(ISO8601::Errors::DurationBaseError)
    end

    it "should return the result of the addition" do
      expect((ISO8601::Duration.new('P11Y1M1DT1H1M1S') + ISO8601::Duration.new('P1Y1M1DT1H1M1S')).to_s).to eq('P12Y2M2DT2H2M2S')
      expect((ISO8601::Duration.new('P1Y1M1DT1H1M1S') + ISO8601::Duration.new('PT10S')).to_s).to eq('P1Y1M1DT1H1M11S')
      expect(ISO8601::Duration.new('P1Y1M1DT1H1M1S') + ISO8601::Duration.new('PT10S')).to be_an_instance_of(ISO8601::Duration)
    end

    it "should perform addition operation with Numeric class" do
      day = 60 * 60 * 24
      expect((ISO8601::Duration.new('P11Y1M1DT1H1M1S') + day).to_s).to eq('P11Y1M2DT1H1M1S')
      expect((ISO8601::Duration.new('P11Y1M1DT1H1M1S') + (2 * day).to_f).to_s).to eq('P11Y1M3DT1H1M1S')
    end

    it "should raise ISO8601::Errors::TypeError when other object is not Numeric or ISO8601::Duration" do
      expect { ISO8601::Duration.new('PT1H') + 'wololo' }.to raise_error(ISO8601::Errors::TypeError)
    end
  end

  describe '#-' do
    it "should raise an ISO8601::Errors::DurationBaseError when bases mismatch" do
      expect { ISO8601::Duration.new('PT1H', leap_year) - ISO8601::Duration.new('PT1H') }.to raise_error(ISO8601::Errors::DurationBaseError)
    end

    it "should return the result of the subtraction" do
      expect(ISO8601::Duration.new('P1Y1M1DT1H1M1S') - ISO8601::Duration.new('PT10S')).to be_an_instance_of(ISO8601::Duration)
      expect((ISO8601::Duration.new('P1Y1M1DT1H1M11S') - ISO8601::Duration.new('PT10S')).to_s).to eq('P1Y1M1DT1H1M1S')
      expect((ISO8601::Duration.new('P1Y1M1DT1H1M11S') - ISO8601::Duration.new('P1Y1M1DT1H1M11S')).to_s).to eq('PT0S')
      expect((ISO8601::Duration.new('PT12S') - ISO8601::Duration.new('PT12S')).to_s).to eq('PT0S')
      expect((ISO8601::Duration.new('PT12S') - ISO8601::Duration.new('PT1S')).to_s).to eq('PT11S')
      expect((ISO8601::Duration.new('PT1S') - ISO8601::Duration.new('PT12S')).to_s).to eq('-PT11S')
      expect((ISO8601::Duration.new('PT1S') - ISO8601::Duration.new('-PT12S')).to_s).to eq('PT13S')
    end

    it "should perform subtract operation with Numeric class" do
      day = 60 * 60 * 24
      minute = 60
      expect((ISO8601::Duration.new('P11Y1M1DT1H1M1S') - day).to_s).to eq('P11Y1MT1H1M1S')
      expect((ISO8601::Duration.new('P11Y1M1DT1H1M1S') - (2 * minute).to_f).to_s).to eq('P11Y1M1DT59M1S')
    end
  end

  describe "#to_days" do
    it "should return the days of a duration" do
      expect(ISO8601::Duration.new('P1Y', common_year).to_days).to eq(365)
      expect(ISO8601::Duration.new('P1D').to_days).to eq(1)
    end
  end

  describe '#to_seconds' do
    context 'positive durations' do
      it "should return the seconds of a P[n]Y duration in a common year" do
        expect(ISO8601::Duration.new('P2Y', common_year).to_seconds).to eq(Time.utc(2012, 1) - Time.utc(2010, 1))
      end

      it "should return the seconds of a P[n]Y duration in a leap year" do
        expect(ISO8601::Duration.new('P2Y', leap_year).to_seconds).to eq(Time.utc(2002, 1) - Time.utc(2000, 1))
      end

      it "should return the seconds of a P[n]Y[n]M duration in a common year" do
        expect(ISO8601::Duration.new('P2Y3M', common_year).to_seconds).to eq(Time.utc(2012, 4) - Time.utc(2010, 1))
      end

      it "should return the seconds of a P[n]Y[n]M duration in a leap year" do
        expect(ISO8601::Duration.new('P2Y3M', leap_year).to_seconds).to eq(Time.utc(2002, 4) - Time.utc(2000, 1))
      end

      it "should return the seconds of a P[n]M duration in a common year" do
        expect(ISO8601::Duration.new('P1M', common_year).to_seconds).to eq(2678400)
        expect(ISO8601::Duration.new('P2M', common_year).to_seconds).to eq(Time.utc(2010, 3) - Time.utc(2010, 1))
        expect(ISO8601::Duration.new('P19M', ISO8601::DateTime.new('2012-05-01')).to_seconds).to eq(Time.utc(2014, 12) - Time.utc(2012, 5))
        expect(ISO8601::Duration.new('P14M', common_year).to_seconds).to eq(Time.utc(2011, 3) - Time.utc(2010, 1))
      end

      it "should return the seconds of a P[n]M duration in a leap year" do
        expect(ISO8601::Duration.new('P1M', leap_year).to_seconds).to eq(Time.utc(2000, 2) - Time.utc(2000, 1))
        expect(ISO8601::Duration.new('P2M', leap_year).to_seconds).to eq(Time.utc(2000, 3) - Time.utc(2000, 1))
        expect(ISO8601::Duration.new('P14M', leap_year).to_seconds).to eq(Time.utc(2001, 3) - Time.utc(2000, 1))
      end

      it "should return the seconds of a P[n]Y[n]M[n]D duration" do
        expect(ISO8601::Duration.new('P2Y11D', common_year).to_seconds).to eq(Time.utc(2012, 1, 12) - Time.utc(2010, 1))
        expect(ISO8601::Duration.new('P1Y1M1D', ISO8601::DateTime.new('2010-05-01')).to_seconds).to eq(Time.utc(2011, 6, 2) - Time.utc(2010, 5))
      end

      it "should return the seconds of a P[n]D duration" do
        expect(ISO8601::Duration.new('P1D', common_year).to_seconds).to eq(Time.utc(2010, 1, 2) - Time.utc(2010, 1, 1))
        expect(ISO8601::Duration.new('P11D', common_year).to_seconds).to eq(Time.utc(2010, 1, 12) - Time.utc(2010, 1, 1))
        expect(ISO8601::Duration.new('P3M11D', common_year).to_seconds).to eq(Time.utc(2010, 4, 12) - Time.utc(2010, 1))
      end

      it "should return the seconds of a P[n]W duration" do
        expect(ISO8601::Duration.new('P2W').to_seconds).to eq(1209600)
      end

      it "should return the seconds of a PT[n]H duration" do
        expect(ISO8601::Duration.new('PT5H').to_seconds).to eq(18000)
        expect(ISO8601::Duration.new('P1YT5H', common_year).to_seconds).to eq(Time.utc(2011, 1, 1, 5) - Time.utc(2010, 1))
      end

      it "should return the seconds of a PT[n]H[n]M duration" do
        expect(ISO8601::Duration.new('PT5M').to_seconds).to eq(60 * 5)
        expect(ISO8601::Duration.new('PT1H5M').to_seconds).to eq(3900)
      end

      it "should return the seconds of a PT[n]H[n]M duration" do
        expect(ISO8601::Duration.new('PT10S').to_seconds).to eq(10)
        expect(ISO8601::Duration.new('PT10.4S').to_seconds).to eq(10.4)
      end
    end

    context 'negative durations' do
      it "should return the seconds of a -P[n]Y duration" do
        expect(ISO8601::Duration.new('-P2Y', common_year).to_seconds).to eq(Time.utc(2008, 1) - Time.utc(2010, 1))
      end

      it "should return the seconds of a -P[n]Y duration in a leap year" do
        expect(ISO8601::Duration.new('-P2Y', ISO8601::DateTime.new('2001-01-01')).to_seconds).to eq(Time.utc(1999, 1) - Time.utc(2001, 1))
      end

      it "should return the seconds of a -P[n]Y[n]M duration in a common year" do
        expect(ISO8601::Duration.new('-P2Y3M', ISO8601::DateTime.new('2010-01-01')).to_seconds).to eq(Time.utc(2007, 10) - Time.utc(2010, 1))
      end

      it "should return the seconds of a -P[n]Y[n]M duration in a leap year" do
        expect(ISO8601::Duration.new('-P2Y3M', ISO8601::DateTime.new('2001-01-01')).to_seconds).to eq(Time.utc(1998, 10) - Time.utc(2001, 1))
      end

      it "should return the seconds of a -P[n]M duration in a common year" do
        expect(ISO8601::Duration.new('-P1M', ISO8601::DateTime.new('2012-01-01')).to_seconds).to eq(Time.utc(2011, 12) - Time.utc(2012, 1))
        expect(ISO8601::Duration.new('-P1M', ISO8601::DateTime.new('2012-02-01')).to_seconds).to eq(Time.utc(2012, 1) - Time.utc(2012, 2))
        expect(ISO8601::Duration.new('-P2M', ISO8601::DateTime.new('2012-03-01')).to_seconds).to eq(Time.utc(2012, 1) - Time.utc(2012, 3))
        expect(ISO8601::Duration.new('-P36M', ISO8601::DateTime.new('2013-03-01')).to_seconds).to eq(Time.utc(2010, 3) - Time.utc(2013, 3))
        expect(ISO8601::Duration.new('-P39M', ISO8601::DateTime.new('2013-03-01')).to_seconds).to eq(Time.utc(2009, 12) - Time.utc(2013, 3))
        expect(ISO8601::Duration.new('-P156M', ISO8601::DateTime.new('2013-03-01')).to_seconds).to eq(Time.utc(2000, 3) - Time.utc(2013, 3))
      end

      it "should return the seconds of a -P[n]M duration in a leap year" do
        expect(ISO8601::Duration.new('-P1M', ISO8601::DateTime.new('2000-02-01')).to_seconds).to eq(Time.utc(2000, 1) - Time.utc(2000, 2))
        expect(ISO8601::Duration.new('-P2M', ISO8601::DateTime.new('2000-03-01')).to_seconds).to eq(Time.utc(2000, 1) - Time.utc(2000, 3))
        expect(ISO8601::Duration.new('-P14M', ISO8601::DateTime.new('2001-03-01')).to_seconds).to eq(Time.utc(2000, 1) - Time.utc(2001, 3))
      end

      it "should return the seconds of a -P[n]Y[n]M[n]D duration" do
        expect(ISO8601::Duration.new('-P2Y11D', ISO8601::DateTime.new('2014-01-12')).to_seconds).to eq(Time.utc(2012, 1) - Time.utc(2014, 1, 12))
        expect(ISO8601::Duration.new('-P1Y1M1D', ISO8601::DateTime.new('2010-05-01')).to_seconds).to eq(Time.utc(2009, 3, 31) - Time.utc(2010, 5))
      end

      it "should return the seconds of a -P[n]D duration" do
        expect(ISO8601::Duration.new('-P1D', ISO8601::DateTime.new('2012-01-02')).to_seconds).to eq(Time.utc(2012, 1) - Time.utc(2012, 1, 2))
        expect(ISO8601::Duration.new('-P11D', ISO8601::DateTime.new('2012-01-12')).to_seconds).to eq(Time.utc(2012, 1) - Time.utc(2012, 1, 12))
        expect(ISO8601::Duration.new('-P3M11D', ISO8601::DateTime.new('2012-04-12')).to_seconds).to eq(Time.utc(2012, 1) - Time.utc(2012, 4, 12))
      end

      it "should return the seconds of a -P[n]W duration" do
        expect(ISO8601::Duration.new('-P2W', ISO8601::DateTime.new('2012-01-15')).to_seconds).to eq(Time.utc(2012, 1) - Time.utc(2012, 1, 15))
        expect(ISO8601::Duration.new('-P2W', ISO8601::DateTime.new('2012-02-01')).to_seconds).to eq(Time.utc(2012, 2) - Time.utc(2012, 2, 15))
      end

      it "should return the seconds of a -PT[n]H duration" do
        expect(ISO8601::Duration.new('-PT5H', ISO8601::DateTime.new('2012-01-01T05')).to_seconds).to eq(Time.utc(2012, 1) - Time.utc(2012, 1, 1, 5))
        expect(ISO8601::Duration.new('-P1YT5H', ISO8601::DateTime.new('2013-01-01T05')).to_seconds).to eq(Time.utc(2012, 1) - Time.utc(2013, 1, 1, 5))
      end

      it "should return the seconds of a -PT[n]H[n]M duration" do
        expect(ISO8601::Duration.new('-PT5M', ISO8601::DateTime.new('2012-01-01T00:05')).to_seconds).to eq(Time.utc(2012, 1) - Time.utc(2012, 1, 1, 0, 5))
        expect(ISO8601::Duration.new('-PT1H5M', ISO8601::DateTime.new('2012-01-01T01:05')).to_seconds).to eq(Time.utc(2012, 1) - Time.utc(2012, 1, 1, 1, 5))
        expect(ISO8601::Duration.new('-PT1H5M', ISO8601::DateTime.new('2012-01-01')).to_seconds).to eq(ISO8601::Duration.new('-PT65M', ISO8601::DateTime.new('2012-01-01')).to_seconds)
      end

      it "should return the seconds of a -PT[n]H[n]M duration" do
        expect(ISO8601::Duration.new('-PT10S', ISO8601::DateTime.new('2012-01-01T00:00:00')).to_seconds).to eq(Time.utc(2011, 12, 31, 23, 59, 50) - Time.utc(2012, 1))
        expect(ISO8601::Duration.new('-PT10.4S', ISO8601::DateTime.new('2012-01-01')).to_seconds).to eq(-10.4)
        expect(ISO8601::Duration.new('-PT10,4S', ISO8601::DateTime.new('2012-01-01')).to_seconds).to eq(-10.4)
      end
    end
  end

  describe '#abs' do
    let(:positive) { ISO8601::Duration.new('PT1H') }
    let(:negative) { ISO8601::Duration.new('-PT1H') }

    it "should return a kind of duration" do
      expect(negative.abs).to be_instance_of(ISO8601::Duration)
    end

    it "should return the absolute value of the duration" do
      expect(negative.abs).to eq(positive)
    end
  end

  describe '#==' do
    it "should equal by computed value" do
      expect(ISO8601::Duration.new('PT1H') == ISO8601::Duration.new('PT1H')).to be_truthy
      expect(ISO8601::Duration.new('PT1H') == ISO8601::Duration.new('PT60M')).to be_truthy
    end

    it "should equal by a Numeric value" do
      hour = 60 * 60
      expect(ISO8601::Duration.new('PT1H') == hour).to be_truthy
      expect(ISO8601::Duration.new('PT2H') == hour).to be_falsy
    end
  end

  describe '#eql?' do
    it "should respond to #eql?" do
      subject = ISO8601::Duration.new('PT1H')
      expect(subject).to respond_to(:eql?)
    end

    it "should equal by hash identity" do
      expect(ISO8601::Duration.new('PT1H').eql? ISO8601::Duration.new('PT1H')).to be_truthy
      expect(ISO8601::Duration.new('PT1H').eql? ISO8601::Duration.new('PT60M')).to be_falsy
    end
  end

  describe '#hash' do
    it "should respond to #hash" do
      expect(ISO8601::Duration.new('PT1H')).to respond_to(:hash)
    end

    it "should build hash identity by value" do
      expect(ISO8601::Duration.new('PT1H').hash).to eq(ISO8601::Duration.new('PT1H').hash)
    end
  end
end
