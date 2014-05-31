# encoding: utf-8

require 'spec_helper'

describe ISO8601::DateTime do
  it "should raise a ISO8601::Errors::UnknownPattern for any unknown pattern" do
    expect { ISO8601::DateTime.new('2') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::DateTime.new('20') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::DateTime.new('201') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::DateTime.new('2010-') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::DateTime.new('2010-') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::DateTime.new('20-05') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::DateTime.new('2010-0') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::DateTime.new('2010-0-09') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::DateTime.new('2010-1-09') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::DateTime.new('201001-09') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::DateTime.new('201-0109') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::DateTime.new('2010-05-09T103012+0400') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::DateTime.new('20100509T10:30:12+04:00') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::DateTime.new('2010-05T10:30:12Z') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::DateTime.new('2010T10:30:12Z') }.to raise_error(ISO8601::Errors::UnknownPattern)
  end

  it "should raise an ArgumentError for a correct pattern but an invalid date" do
    expect { ISO8601::DateTime.new('2010-01-32') }.to raise_error(ArgumentError)
    expect { ISO8601::DateTime.new('2010-02-30') }.to raise_error(ArgumentError)
    expect { ISO8601::DateTime.new('2010-13-30') }.to raise_error(ArgumentError)
    expect { ISO8601::DateTime.new('2010-12-30T25:00:00') }.to raise_error(ArgumentError)
  end

  it "should parse any allowed pattern" do
    expect { ISO8601::DateTime.new('2010') }.to_not raise_error
    expect { ISO8601::DateTime.new('2010-05') }.to_not raise_error
    expect { ISO8601::DateTime.new('2010-05-09') }.to_not raise_error
    expect { ISO8601::DateTime.new('2010-05-09T10') }.to_not raise_error
    expect { ISO8601::DateTime.new('2010-05-09T10:30') }.to_not raise_error
    expect { ISO8601::DateTime.new('2010-05-09T10:30:12') }.to_not raise_error
    expect { ISO8601::DateTime.new('2010-05-09T10:30:12Z') }.to_not raise_error
    expect { ISO8601::DateTime.new('2010-05-09T10:30:12+04') }.to_not raise_error
    expect { ISO8601::DateTime.new('2010-05-09T10:30:12+04:00') }.to_not raise_error
    expect { ISO8601::DateTime.new('2010-05-09T10:30:12-04:00') }.to_not raise_error
    expect { ISO8601::DateTime.new('2010-05-09T10:30:12+0400') }.to_not raise_error
    expect { ISO8601::DateTime.new('2010-05-09T10:30:12-00:00') }.to_not raise_error
    expect { ISO8601::DateTime.new('-2014-05-31T16:26:00Z') }.to_not raise_error
  end

  it "should parse correctly any allowed reduced pattern" do
    expect { ISO8601::DateTime.new('20100509') }.to_not raise_error
    ISO8601::DateTime.new('20100509').year.should == 2010
    ISO8601::DateTime.new('20100509').month.should == 5
    ISO8601::DateTime.new('20100509').day.should == 9

    expect { ISO8601::DateTime.new('20100509T103012') }.to_not raise_error
    expect { ISO8601::DateTime.new('20100509T103012Z') }.to_not raise_error
    expect { ISO8601::DateTime.new('20100509T103012+04') }.to_not raise_error
    expect { ISO8601::DateTime.new('20100509T103012+0400') }.to_not raise_error
    expect { ISO8601::DateTime.new('20100509T103012-0400') }.to_not raise_error
  end

  it "should return each atomic value" do
    dt = ISO8601::DateTime.new('2010-05-09T12:02:01+04:00')
    dt.year.should == 2010
    dt.month.should == 5
    dt.day.should == 9
    dt.hour.should == 12
    dt.minute.should == 2
    dt.second.should == 1
    dt.zone.should == '+04:00'
  end

  it "should return the right sign for the given year" do
    ISO8601::DateTime.new('-2014-05-31T16:26:00Z').year.should == -2014
    ISO8601::DateTime.new('+2014-05-31T16:26:00Z').year.should == 2014
  end

  context "delegated methods" do
    it "should return the string representation" do
      ISO8601::DateTime.new('2010-05-09').to_s.should == '2010-05-09T00:00:00+00:00'
    end
    it "should return a Time instance" do
      ISO8601::DateTime.new('2010-05-09T12:02:01Z').to_time.should be_an_instance_of(Time)
    end
  end

  describe '#+' do
    it "should return the result of the addition" do
      (ISO8601::DateTime.new('2012-07-07T20:20:20Z') + 10).to_time.should == ISO8601::DateTime.new('2012-07-07T20:20:30Z').to_time
    end
  end

  describe '#-' do
    it "should return the result of the substraction" do
      (ISO8601::DateTime.new('2012-07-07T20:20:20Z') - 10).to_time.should == ISO8601::DateTime.new('2012-07-07T20:20:10+00:00').to_time
    end
  end
end
