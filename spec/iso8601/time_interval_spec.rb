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

    it "should raise a ISO8601::Errors::UnknownPattern if start time and end time are durations" do
      expect { ISO8601::TimeInterval.new('P1Y2M10D/P1Y2M10D') }.to raise_error(ISO8601::Errors::UnknownPattern)
      expect { ISO8601::TimeInterval.new('P1Y0.5M/P1Y0.5M') }.to raise_error(ISO8601::Errors::UnknownPattern)
    end

    context "allowed patterns" do
      it "should parse <start>/<duration>" do
        expect { ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/P1Y') }.to_not raise_error
        expect { ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/P0.5Y') }.to_not raise_error
        expect { ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/P1Y0.5M') }.to_not raise_error
        expect { ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/P1Y0,5M') }.to_not raise_error
        expect { ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/P1Y1M1D') }.to_not raise_error
        expect { ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/P1Y1M1DT1H1M1.0S') }.to_not raise_error
        expect { ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/P1Y1M1DT1H1M1,0S') }.to_not raise_error
      end

      it "should parse <duration>/<end>" do
        expect { ISO8601::TimeInterval.new('P1Y0,5M/2010-05-09T10:30:12+04') }.to_not raise_error
        expect { ISO8601::TimeInterval.new('P1Y1M1D/2010-05-09T10:30:12+04:00') }.to_not raise_error
        expect { ISO8601::TimeInterval.new('P1Y1M0.5D/2010-05-09T10:30:12-04:00') }.to_not raise_error
        expect { ISO8601::TimeInterval.new('P1Y1M0,5D/2010-05-09T10:30:12-00:00') }.to_not raise_error
        expect { ISO8601::TimeInterval.new('P1Y1M1DT1H/-2014-05-31T16:26:00Z') }.to_not raise_error
        expect { ISO8601::TimeInterval.new('P1Y1M1DT0.5H/2014-05-31T16:26:10.5Z') }.to_not raise_error
        expect { ISO8601::TimeInterval.new('P1Y1M1DT0,5H/2014-05-31T16:26:10,5Z') }.to_not raise_error
      end

      it "should parse <start>/<end>" do
        expect { ISO8601::TimeInterval.new('2014-001/2010-05-09T10:30') }.to_not raise_error
        expect { ISO8601::TimeInterval.new('2014121/2010-05-09T10:30:12') }.to_not raise_error
        expect { ISO8601::TimeInterval.new('2014-121T10:11:12Z/2010-05-09T10:30:12Z') }.to_not raise_error
        expect { ISO8601::TimeInterval.new('20100509T103012+0400/2010-05-09T10:30:12+04') }.to_not raise_error
        expect { ISO8601::TimeInterval.new('20100509/2010-05-09T10:30:12+04:00') }.to_not raise_error
        expect { ISO8601::TimeInterval.new('T103012+0400/2010-05-09T10:30:12-04:00') }.to_not raise_error
        expect { ISO8601::TimeInterval.new('T103012+04/2010-05-09T10:30:12-00:00') }.to_not raise_error
      end
    end
  end

  describe 'initialization with a ISO8601::Duration' do
    it "should raise a ArgumentError if parameter is not a ISO8601::Duration" do
      datetime = ISO8601::DateTime.new('2010-05-09T10:30:12Z')

      expect { ISO8601::TimeInterval.from_duration('hi', {}) }.to raise_error(ArgumentError)
      expect { ISO8601::TimeInterval.from_duration([], {}) }.to raise_error(ArgumentError)
      expect { ISO8601::TimeInterval.from_duration(datetime, {}) }.to raise_error(ArgumentError)
      expect { ISO8601::TimeInterval.from_duration({}, {}) }.to raise_error(ArgumentError)
    end

    it "should raise an ArgumentError if the time hash is no valid" do
      duration = ISO8601::Duration.new('P1Y1M1DT0.5H')
      datetime = ISO8601::DateTime.new('2010-05-09T10:30:12Z')

      expect { ISO8601::TimeInterval.from_duration(duration, { time: datetime }) }.to raise_error(ArgumentError)
      expect { ISO8601::TimeInterval.from_duration(duration, { start_time: nil }) }.to raise_error(ArgumentError)
      expect { ISO8601::TimeInterval.from_duration(duration, { start_time: datetime, end_time: datetime }) }.to raise_error(ArgumentError)
      expect { ISO8601::TimeInterval.from_duration(duration, {}) }.to raise_error(ArgumentError)
    end

    it "should initialize with a valid duration and time" do
      time = ISO8601::DateTime.new('2010-05-09T10:30:12Z')
      duration = ISO8601::Duration.new('P1M')

      expect { ISO8601::TimeInterval.from_duration(duration, { start_time: time }) }.to_not raise_error
      expect { ISO8601::TimeInterval.from_duration(duration, { end_time: time }) }.to_not raise_error
    end
  end

  describe 'initialization with a ISO8601::DateTime' do
    it "should raise a ArgumentError if parameters are not an ISO8601::DateTime instance" do
      duration = ISO8601::Duration.new('P1Y1M1DT0.5H')
      datetime = ISO8601::DateTime.new('2010-05-09T10:30:12Z')

      expect { ISO8601::TimeInterval.from_datetimes(duration, datetime) }.to raise_error(ArgumentError)
      expect { ISO8601::TimeInterval.from_datetimes(datetime, duration) }.to raise_error(ArgumentError)
      expect { ISO8601::TimeInterval.from_datetimes(datetime, 'Hello!') }.to raise_error(ArgumentError)
      expect { ISO8601::TimeInterval.from_datetimes({}, datetime) }.to raise_error(ArgumentError)
    end

    it "should initialize class with a valid datetimes" do
      datetime = ISO8601::DateTime.new('2010-05-09T10:30:12Z')
      datetime2 = ISO8601::DateTime.new('2010-05-15T10:30:12Z')

      expect { ISO8601::TimeInterval.from_datetimes(datetime, datetime2) }.to_not raise_error
      expect { ISO8601::TimeInterval.from_datetimes(datetime2, datetime) }.to_not raise_error
    end
  end

  describe "#to_f" do
    it "should calculate the size of time interval" do
      hour = (60 * 60).to_f
      pattern = 'PT1H/2010-05-09T10:30:00Z'
      pattern2 = '2010-05-09T11:30:00Z/PT1H'
      pattern3 = '2010-05-09T11:30:00Z/2010-05-09T12:30:00Z'

      expect(ISO8601::TimeInterval.new(pattern).to_f).to eq(hour)
      expect(ISO8601::TimeInterval.new(pattern2).to_f).to eq(hour)
      expect(ISO8601::TimeInterval.new(pattern3).to_f).to eq(hour)
    end
  end

  describe "#start_time" do
    it "should return always a ISO8601::DateTime object" do
      pattern = 'PT1H/2010-05-09T10:30:00Z'
      pattern2 = '2010-05-09T11:30:00Z/PT1H'
      pattern3 = '2010-05-09T11:30:00Z/2010-05-09T12:30:00Z'

      expect(ISO8601::TimeInterval.new(pattern).start_time).to be_an_instance_of(ISO8601::DateTime)
      expect(ISO8601::TimeInterval.new(pattern2).start_time).to be_an_instance_of(ISO8601::DateTime)
      expect(ISO8601::TimeInterval.new(pattern3).start_time).to be_an_instance_of(ISO8601::DateTime)
    end

    it "should calculate correctly the start_time" do
      start_time = ISO8601::DateTime.new('2010-05-09T10:30:00Z')
      pattern = 'PT1H/2010-05-09T11:30:00Z'
      pattern2 = '2010-05-09T10:30:00Z/PT1H'
      pattern3 = '2010-05-09T10:30:00Z/2010-05-09T12:30:00Z'

      expect(ISO8601::TimeInterval.new(pattern).start_time).to eq(start_time)
      expect(ISO8601::TimeInterval.new(pattern2).start_time).to eq(start_time)
      expect(ISO8601::TimeInterval.new(pattern3).start_time).to eq(start_time)
    end
  end

  describe "#original_start_time" do
    it "should return an instance of original pattern/object" do
      pattern = 'PT1H/2010-05-09T11:30:00Z'
      pattern2 = '2010-05-09T10:30:00Z/PT1H'
      pattern3 = '2010-05-09T10:30:00Z/2010-05-09T12:30:00Z'

      expect(ISO8601::TimeInterval.new(pattern).original_start_time).to be_an_instance_of(ISO8601::Duration)
      expect(ISO8601::TimeInterval.new(pattern2).original_start_time).to be_an_instance_of(ISO8601::DateTime)
      expect(ISO8601::TimeInterval.new(pattern3).original_start_time).to be_an_instance_of(ISO8601::DateTime)
    end
  end

  describe "#end_time" do
    it "should return always a ISO8601::DateTime object" do
      pattern = 'PT1H/2010-05-09T10:30:00Z'
      pattern2 = '2010-05-09T11:30:00Z/PT1H'
      pattern3 = '2010-05-09T11:30:00Z/2010-05-09T12:30:00Z'

      expect(ISO8601::TimeInterval.new(pattern).end_time).to be_an_instance_of(ISO8601::DateTime)
      expect(ISO8601::TimeInterval.new(pattern2).end_time).to be_an_instance_of(ISO8601::DateTime)
      expect(ISO8601::TimeInterval.new(pattern3).end_time).to be_an_instance_of(ISO8601::DateTime)
    end

    it "should calculate correctly the end_time" do
      end_time = ISO8601::DateTime.new('2010-05-09T10:30:00Z')
      pattern = 'PT1H/2010-05-09T10:30:00Z'
      pattern2 = '2010-05-09T09:30:00Z/PT1H'
      pattern3 = '2010-05-09T09:30:00Z/2010-05-09T10:30:00Z'

      expect(ISO8601::TimeInterval.new(pattern).end_time).to eq(end_time)
      expect(ISO8601::TimeInterval.new(pattern2).end_time).to eq(end_time)
      expect(ISO8601::TimeInterval.new(pattern3).end_time).to eq(end_time)
    end
  end

  describe "#original_end_time" do
    it "should return an instance of original pattern/object" do
      pattern = 'PT1H/2010-05-09T10:30:00Z'
      pattern2 = '2010-05-09T09:30:00Z/PT1H'
      pattern3 = '2010-05-09T09:30:00Z/2010-05-09T10:30:00Z'

      expect(ISO8601::TimeInterval.new(pattern).original_end_time).to be_an_instance_of(ISO8601::DateTime)
      expect(ISO8601::TimeInterval.new(pattern2).original_end_time).to be_an_instance_of(ISO8601::Duration)
      expect(ISO8601::TimeInterval.new(pattern3).original_end_time).to be_an_instance_of(ISO8601::DateTime)
    end
  end

  describe "#to_s" do
    it "should return the pattern if TimeInterval is initialized with a pattern" do
      pattern = 'P1Y1M1DT0,5H/2014-05-31T16:26:10,5Z'
      pattern2 = '2007-03-01T13:00:00Z/P1Y0,5M'

      expect(ISO8601::TimeInterval.new(pattern).to_s).to eq(pattern)
      expect(ISO8601::TimeInterval.new(pattern2).to_s).to eq(pattern2)
    end

    it "should build the pattern and return if TimeInterval is initialized with objects" do
      duration = ISO8601::Duration.new('P1Y1M1DT0.5H')
      datetime = ISO8601::DateTime.new('2010-05-09T10:30:12+00:00')
      datetime2 = ISO8601::DateTime.new('2010-05-15T10:30:12+00:00')

      expect(ISO8601::TimeInterval.from_duration(duration, { end_time: datetime }).to_s).to eq('P1Y1M1DT0.5H/2010-05-09T10:30:12+00:00')
      expect(ISO8601::TimeInterval.from_duration(duration, { start_time: datetime }).to_s).to eq('2010-05-09T10:30:12+00:00/P1Y1M1DT0.5H')
      expect(ISO8601::TimeInterval.from_datetimes(datetime, datetime2).to_s).to eq('2010-05-09T10:30:12+00:00/2010-05-15T10:30:12+00:00')
    end
  end

  describe "compare Time Intervals" do
    before(:each) do
      @small = ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/PT1H')
      @big = ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/PT2H')
    end

    it "should raise TypeError when compared object is not a ISO8601::TimeInterval" do
      expect { @small < 'Hello!' }.to raise_error(ArgumentError)
      expect { @small > 'Hello!' }.to raise_error(ArgumentError)
    end

    it "should check what interval is bigger" do
      expect(@small <=> @big).to eq(-1)
      expect(@big <=> @small).to eq(1)
      expect(@big <=> @big).to eq(0)

      expect(@small > @big).to be_falsy
      expect(@big > @small).to be_truthy
      expect(@small > @small).to be_falsy
    end

    it "should check if interval is bigger or equal than other" do
      expect(@small >= @big).to be_falsy
      expect(@big >= @small).to be_truthy
      expect(@small >= @small).to be_truthy
    end

    it "should check what interval is smaller" do
      expect(@small < @big).to be_truthy
      expect(@big < @small).to be_falsy
      expect(@small < @small).to be_falsy
    end

    it "should check if interval is smaller or equal than other" do
      expect(@small <= @big).to be_truthy
      expect(@big <= @small).to be_falsy
      expect(@small <= @small).to be_truthy
    end

    it "should check if the intervals are equals" do
      expect(@small == @small).to be_truthy
      expect(@small == @small.to_f).to be_falsy
      expect(@small == @big).to be_falsy
      expect(@small == @big.to_f).to be_falsy
    end
  end

  describe "#eql?" do
    it "should be equal only when start_time and end_time are the same" do
      interval = ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/PT1H')
      interval2 = ISO8601::TimeInterval.new('2007-03-01T14:00:00Z/PT1H')
      interval3 = ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/PT1H')

      expect(interval.eql?(interval2)).to be_falsy
      expect(interval.eql?(interval3)).to be_truthy
    end
  end

  describe "#include?" do
    it "raise TypeError when the parameter is not valid" do
      ti = ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/PT1H')
      expect { ti.include?('hola') }.to raise_error(ISO8601::Errors::TypeError)
      expect { ti.include?(123) }.to raise_error(ISO8601::Errors::TypeError)
    end

    it "should check if a DateTime is included" do
      ti = ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/P1DT1H')
      included = DateTime.new(2007, 3, 1, 15, 0, 0)
      included_iso8601 = ISO8601::DateTime.new('2007-03-01T18:00:00Z')
      not_included = DateTime.new(2007, 2, 1, 15, 0, 0)
      not_included_iso8601 = ISO8601::DateTime.new('2007-03-01T11:00:00Z')

      expect(ti.include?(included)).to be_truthy
      expect(ti.include?(included_iso8601)).to be_truthy
      expect(ti.include?(not_included)).to be_falsy
      expect(ti.include?(not_included_iso8601)).to be_falsy
    end

    it "should check if an interval is included" do
      ti = ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/P1DT1H')
      included = ISO8601::TimeInterval.new('2007-03-01T14:00:00Z/PT2H')
      not_included = ISO8601::TimeInterval.new('2007-03-05T14:00:00Z/PT2H')
      overlaped = ISO8601::TimeInterval.new('2007-03-01T18:00:00Z/P1DT1H')

      expect(ti.include?(included)).to be_truthy
      expect(ti.include?(not_included)).to be_falsy
      expect(ti.include?(overlaped)).to be_falsy
    end
  end

  describe "#overlap?" do
    it "raise TypeError when the parameter is not valid" do
      ti = ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/PT1H')
      dt = DateTime.new(2007, 2, 1, 15, 0, 0)
      dt_iso8601 = ISO8601::DateTime.new('2007-03-01T18:00:00Z')

      expect { ti.overlap?('hola') }.to raise_error(ISO8601::Errors::TypeError)
      expect { ti.overlap?(123) }.to raise_error(ISO8601::Errors::TypeError)
      expect { ti.overlap?(dt) }.to raise_error(ISO8601::Errors::TypeError)
      expect { ti.overlap?(dt_iso8601) }.to raise_error(ISO8601::Errors::TypeError)
    end

    it "should check if two Intervals are overlapped" do
      ti = ISO8601::TimeInterval.new('2007-03-01T13:00:00Z/P1DT1H')
      included = ISO8601::TimeInterval.new('2007-03-01T14:00:00Z/PT2H')
      overlaped = ISO8601::TimeInterval.new('2007-03-01T18:00:00Z/P1DT1H')
      not_overlaped = ISO8601::TimeInterval.new('2007-03-14T14:00:00Z/PT2H')

      expect(ti.overlap?(included)).to be_truthy
      expect(ti.overlap?(overlaped)).to be_truthy
      expect(ti.overlap?(not_overlaped)).to be_falsy
    end
  end
end
