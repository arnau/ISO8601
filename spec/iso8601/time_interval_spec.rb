# encoding: utf-8

require 'spec_helper'

RSpec.describe ISO8601::TimeInterval do
  describe 'pattern initialization' do
    it "should raise a ISO8601::Errors::UnknownPattern if it not a valid interval pattern" do
      # Invalid separators
      expect { ISO8601::TimeInterval.new('2007-03-01T13:00:00ZP1Y2M10DT2H30M') }
        .to raise_error(ISO8601::Errors::UnknownPattern)
      expect { ISO8601::TimeInterval.new('2007-03-01T13:00:00Z-P1Y2M10D') }
        .to raise_error(ISO8601::Errors::UnknownPattern)
      expect { ISO8601::TimeInterval.new('2007-03-01T13:00:00Z~P1Y2M10D') }
        .to raise_error(ISO8601::Errors::UnknownPattern)
      expect { ISO8601::TimeInterval.new('P1Y2M10DT2H30M2007-03-01T13:00:00Z') }
        .to raise_error(ISO8601::Errors::UnknownPattern)
      expect { ISO8601::TimeInterval.new('P1Y2M10D-2007-03-01T13:00:00Z') }
        .to raise_error(ISO8601::Errors::UnknownPattern)
      expect { ISO8601::TimeInterval.new('P1Y2M10D~2007-03-01T13:00:00Z') }
        .to raise_error(ISO8601::Errors::UnknownPattern)
      expect { ISO8601::TimeInterval.new('2007-03-01T13:00:00Z2008-05-11T15:30:00Z') }
        .to raise_error(ISO8601::Errors::UnknownPattern)
      expect { ISO8601::TimeInterval.new('2007-03-01T13:00:00Z-2008-05-11T15:30:00Z') }
        .to raise_error(ISO8601::Errors::UnknownPattern)
      expect { ISO8601::TimeInterval.new('2007-03-01T13:00:00Z~2008-05-11T15:30:00Z') }
        .to raise_error(ISO8601::Errors::UnknownPattern)
    end

    describe 'with duration' do
      it "should raise a ISO8601::Errors::UnknownPattern for any unknown pattern" do
        expect { ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/') }
          .to raise_error(ISO8601::Errors::UnknownPattern)
        expect { ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/P') }
          .to raise_error(ISO8601::Errors::UnknownPattern)
        expect { ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/PT') }
          .to raise_error(ISO8601::Errors::UnknownPattern)
      end
    end

    describe 'with DateTimes' do
      it "should raise a ISO8601::Errors::UnknownPattern for any unknown pattern" do
        expect { ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/2010-0-09') }
          .to raise_error(ISO8601::Errors::UnknownPattern)
        expect { ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/2010-05-09T103012+0400') }
          .to raise_error(ISO8601::Errors::UnknownPattern)
        expect { ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/2014-W15-02T10:11:12Z') }
          .to raise_error(ISO8601::Errors::UnknownPattern)
      end
    end

    it "should raise a ISO8601::Errors::TypeError if start time and end time are durations" do
      expect { ISO8601::TimeInterval.new('P1Y2M10D/P1Y2M10D') }.to raise_error(ISO8601::Errors::TypeError)
      expect { ISO8601::TimeInterval.new('P1Y0.5M/P1Y0.5M') }.to raise_error(ISO8601::Errors::TypeError)
    end

    it "should parse any allowed pattern" do
      expect { ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/P1Y') }.to_not raise_error
      expect { ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/P0.5Y') }.to_not raise_error
      expect { ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/P1Y0.5M') }.to_not raise_error
      expect { ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/P1Y0,5M') }.to_not raise_error
      expect { ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/P1Y1M1D') }.to_not raise_error
      expect { ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/P1Y1M1DT1H1M1.0S') }.to_not raise_error
      expect { ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/P1Y1M1DT1H1M1,0S') }.to_not raise_error

      expect { ISO8601::TimeInterval.new('P1Y0,5M/2010-05-09T10:30:12+04') }.to_not raise_error
      expect { ISO8601::TimeInterval.new('P1Y1M1D/2010-05-09T10:30:12+04:00') }.to_not raise_error
      expect { ISO8601::TimeInterval.new('P1Y1M0.5D/2010-05-09T10:30:12-04:00') }.to_not raise_error
      expect { ISO8601::TimeInterval.new('P1Y1M0,5D/2010-05-09T10:30:12-00:00') }.to_not raise_error
      expect { ISO8601::TimeInterval.new('P1Y1M1DT1H/-2014-05-31T16:26:00Z') }.to_not raise_error
      expect { ISO8601::TimeInterval.new('P1Y1M1DT0.5H/2014-05-31T16:26:10.5Z') }.to_not raise_error
      expect { ISO8601::TimeInterval.new('P1Y1M1DT0,5H/2014-05-31T16:26:10,5Z') }.to_not raise_error

      expect { ISO8601::TimeInterval.new('2014-001/2010-05-09T10:30') }.to_not raise_error
      expect { ISO8601::TimeInterval.new('2014121/2010-05-09T10:30:12') }.to_not raise_error
      expect { ISO8601::TimeInterval.new('2014-121T10:11:12Z/2010-05-09T10:30:12Z') }.to_not raise_error
      expect { ISO8601::TimeInterval.new('20100509T103012+0400/2010-05-09T10:30:12+04') }.to_not raise_error
      expect { ISO8601::TimeInterval.new('20100509/2010-05-09T10:30:12+04:00') }.to_not raise_error
      expect { ISO8601::TimeInterval.new('T103012+0400/2010-05-09T10:30:12-04:00') }.to_not raise_error
      expect { ISO8601::TimeInterval.new('T103012+04/2010-05-09T10:30:12-00:00') }.to_not raise_error
    end
  end

  describe 'object initialization' do
    it "should raise a ISO8601::Errors::TypeError if parameters are not a ISO8601::Duration or ISO8601::DateTime instance" do
      duration = ISO8601::Duration.new('P1Y1M1DT0.5H')
      datetime = ISO8601::DateTime.new('2010-05-09T10:30:12Z')

      expect { ISO8601::TimeInterval.new(duration, 'Hello!') }.to raise_error(ISO8601::Errors::TypeError)
      expect { ISO8601::TimeInterval.new([], duration) }.to raise_error(ISO8601::Errors::TypeError)
      expect { ISO8601::TimeInterval.new(datetime, 'Hello!') }.to raise_error(ISO8601::Errors::TypeError)
      expect { ISO8601::TimeInterval.new({}, datetime) }.to raise_error(ISO8601::Errors::TypeError)
    end

    it "should raise a ISO8601::Errors::TypeError if start time and end time are durations" do
      duration = ISO8601::Duration.new('P1Y1M1DT0.5H')
      duration2 = ISO8601::Duration.new('P1Y1M1DT2H')
      expect { ISO8601::TimeInterval.new(duration, duration) }.to raise_error(ISO8601::Errors::TypeError)
      expect { ISO8601::TimeInterval.new(duration, duration2) }.to raise_error(ISO8601::Errors::TypeError)
    end

    it "should raise an ArgumentError if second parameter is nil" do
      duration = ISO8601::Duration.new('P1Y1M1DT0.5H')
      datetime = ISO8601::DateTime.new('2010-05-09T10:30:12Z')

      expect { ISO8601::TimeInterval.new(duration) }.to raise_error(ArgumentError)
      expect { ISO8601::TimeInterval.new(datetime) }.to raise_error(ArgumentError)
      expect { ISO8601::TimeInterval.new(datetime, nil) }.to raise_error(ArgumentError)
      expect { ISO8601::TimeInterval.new(duration, nil) }.to raise_error(ArgumentError)
    end

    it "should initialize class with a valid objects" do
      duration = ISO8601::Duration.new('P1Y1M1DT0.5H')
      datetime = ISO8601::DateTime.new('2010-05-09T10:30:12Z')
      datetime2 = ISO8601::DateTime.new('2010-05-15T10:30:12Z')

      expect { ISO8601::TimeInterval.new(duration, datetime) }.to_not raise_error
      expect { ISO8601::TimeInterval.new(datetime, duration) }.to_not raise_error
      expect { ISO8601::TimeInterval.new(datetime, datetime2) }.to_not raise_error
    end
  end

  describe "#size" do
    it "should calculate the size of time interval" do
      duration = ISO8601::Duration.new('PT1H')
      hour = (60 * 60).to_f
      datetime = ISO8601::DateTime.new('2010-05-09T10:30:00Z')
      datetime2 = ISO8601::DateTime.new('2010-05-09T11:30:00Z')

      expect(ISO8601::TimeInterval.new(duration, datetime).size).to eq(hour)
      expect(ISO8601::TimeInterval.new(datetime, duration).size).to eq(hour)
      expect(ISO8601::TimeInterval.new(datetime, datetime2).size).to eq(hour)
      expect(ISO8601::TimeInterval.new(datetime, datetime).size).to eq(0)
      expect(ISO8601::TimeInterval.new(datetime2, datetime).size).to eq(-hour)
    end
  end

  describe "#start_time" do
    it "should return always a ISO8601::DateTime object" do
      duration = ISO8601::Duration.new('PT1H')
      datetime = ISO8601::DateTime.new('2010-05-09T10:30:00Z')

      expect(ISO8601::TimeInterval.new(duration, datetime).start_time).to be_an_instance_of(ISO8601::DateTime)
      expect(ISO8601::TimeInterval.new(datetime, duration).start_time).to be_an_instance_of(ISO8601::DateTime)
      expect(ISO8601::TimeInterval.new(datetime, datetime).start_time).to be_an_instance_of(ISO8601::DateTime)
    end

    it "should calculate correctly the start_time" do
      start_time = ISO8601::DateTime.new('2010-05-09T10:30:00Z')
      duration = ISO8601::Duration.new('PT1H')

      expect(ISO8601::TimeInterval.new('PT1H/2010-05-09T11:30:00Z').start_time).to eq(start_time)
      expect(ISO8601::TimeInterval.new('2010-05-09T10:30:00Z/PT1H').start_time).to eq(start_time)
      expect(ISO8601::TimeInterval.new(start_time, (start_time + 60 * 60)).start_time).to eq(start_time)
      expect(ISO8601::TimeInterval.new(start_time, duration).start_time).to eq(start_time)
    end
  end

  describe "#end_time" do
    it "should return always a ISO8601::DateTime object" do
      duration = ISO8601::Duration.new('PT1H')
      datetime = ISO8601::DateTime.new('2010-05-09T10:30:00Z')

      expect(ISO8601::TimeInterval.new(duration, datetime).end_time).to be_an_instance_of(ISO8601::DateTime)
      expect(ISO8601::TimeInterval.new(datetime, duration).end_time).to be_an_instance_of(ISO8601::DateTime)
      expect(ISO8601::TimeInterval.new(datetime, datetime).end_time).to be_an_instance_of(ISO8601::DateTime)
    end

    it "should calculate correctly the end_time" do
      end_time = ISO8601::DateTime.new('2010-05-09T10:30:00Z')
      duration = ISO8601::Duration.new('PT1H')

      expect(ISO8601::TimeInterval.new('PT1H/2010-05-09T10:30:00Z').end_time).to eq(end_time)
      expect(ISO8601::TimeInterval.new('2010-05-09T09:30:00Z/PT1H').end_time).to eq(end_time)
      expect(ISO8601::TimeInterval.new((end_time - 60 * 60), end_time).end_time).to eq(end_time)
      expect(ISO8601::TimeInterval.new(end_time, duration).end_time).to eq((end_time + 60 * 60))
    end
  end
end
