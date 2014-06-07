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

  it "should raise a RangeError for a correct pattern but an invalid date" do
    expect { ISO8601::DateTime.new('2010-01-32') }.to raise_error(ISO8601::Errors::RangeError)
    expect { ISO8601::DateTime.new('2010-02-30') }.to raise_error(ISO8601::Errors::RangeError)
    expect { ISO8601::DateTime.new('2010-13-30') }.to raise_error(ISO8601::Errors::RangeError)
    expect { ISO8601::DateTime.new('2010-12-30T25:00:00') }.to raise_error(ISO8601::Errors::RangeError)
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
    expect { ISO8601::DateTime.new('2010-05-09T10:30:12-00:00') }.to_not raise_error
    expect { ISO8601::DateTime.new('-2014-05-31T16:26:00Z') }.to_not raise_error
    expect { ISO8601::DateTime.new('2014-05-31T16:26:10.5Z') }.to_not raise_error
    expect { ISO8601::DateTime.new('2014-05-31T16:26:10,5Z') }.to_not raise_error
    expect { ISO8601::DateTime.new('T10:30:12Z') }.to_not raise_error
    expect { ISO8601::DateTime.new('2014-001') }.to_not raise_error
    expect { ISO8601::DateTime.new('2014121') }.to_not raise_error
    expect { ISO8601::DateTime.new('2014-121T10:11:12Z') }.to_not raise_error
    expect { ISO8601::DateTime.new('20100509T103012+0400') }.to_not raise_error
    expect { ISO8601::DateTime.new('20100509') }.to_not raise_error
    expect { ISO8601::DateTime.new('T103012+0400') }.to_not raise_error
    expect { ISO8601::DateTime.new('T103012+04') }.to_not raise_error
    expect { ISO8601::DateTime.new('T103012+04') }.to_not raise_error
  end

  context 'reduced patterns' do
    it "should parse correctly reduced dates" do
      reduced_date = ISO8601::DateTime.new('20100509')
      reduced_date.year.should == 2010
      reduced_date.month.should == 5
      reduced_date.day.should == 9
    end
    it "should parse correctly reduced times" do
      reduced_time = ISO8601::DateTime.new('T101112Z')
      reduced_time.hour.should == 10
      reduced_time.minute.should == 11
      reduced_time.second.should == 12
    end
    it "should parse correctly reduced date times" do
      reduced_datetime = ISO8601::DateTime.new('20140531T101112Z')
      reduced_datetime.year.should == 2014
      reduced_datetime.month.should == 5
      reduced_datetime.day.should == 31
      reduced_datetime.hour.should == 10
      reduced_datetime.minute.should == 11
      reduced_datetime.second.should == 12
    end
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

  it "should respond to delegated casting methods" do
    dt = ISO8601::DateTime.new('2014-12-11T10:09:08Z')
    dt.should respond_to(:to_s, :to_time, :to_date, :to_datetime)
  end

  describe '#+' do
    it "should return the result of the addition" do
      (ISO8601::DateTime.new('2012-07-07T20:20:20Z') + 10).to_s.should == '2012-07-07T20:20:30+00:00'
      (ISO8601::DateTime.new('2012-07-07T20:20:20.5Z') + 10).to_s.should == '2012-07-07T20:20:30.50+00:00'
      (ISO8601::DateTime.new('2012-07-07T20:20:20+02:00') + 10).to_s.should == '2012-07-07T20:20:30+02:00'
    end
  end

  describe '#-' do
    it "should return the result of the substraction" do
      (ISO8601::DateTime.new('2012-07-07T20:20:20Z') - 10).to_s.should == '2012-07-07T20:20:10+00:00'
    end
  end

  describe '#to_a' do
    it "should return an array of atoms" do
      dt = ISO8601::DateTime.new('2014-05-31T19:29:39Z').to_a
      dt.should be_kind_of(Array)
      dt.should == [2014, 5, 31, 19, 29, 39, '+00:00']
    end
  end
end
