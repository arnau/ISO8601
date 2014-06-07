require 'spec_helper'

describe ISO8601::Time do
  it "should raise an error for any unknown pattern" do
    expect { ISO8601::Time.new('T10:3012+0400') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Time.new('T10:30:12+0400') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Time.new('T10:30:12+040') }.to raise_error(ISO8601::Errors::UnknownPattern)
  end

  it "should raise an error for a correct pattern but an invalid date" do
    expect { ISO8601::Time.new('T25:00:00') }.to raise_error(ISO8601::Errors::RangeError)
    expect { ISO8601::Time.new('T00:61:00') }.to raise_error(ISO8601::Errors::RangeError)
    expect { ISO8601::Time.new('T00:00:61') }.to raise_error(ISO8601::Errors::RangeError)
  end

  it "should parse any allowed pattern" do
    expect { ISO8601::Time.new('T10') }.to_not raise_error
    expect { ISO8601::Time.new('T10:30') }.to_not raise_error
    expect { ISO8601::Time.new('T10:30:12') }.to_not raise_error
    expect { ISO8601::Time.new('T10:30:12Z') }.to_not raise_error
    expect { ISO8601::Time.new('T10:30:12+04') }.to_not raise_error
    expect { ISO8601::Time.new('T10:30:12+04:00') }.to_not raise_error
    expect { ISO8601::Time.new('T10:30:12-04:00') }.to_not raise_error
    expect { ISO8601::Time.new('T103012+0400') }.to_not raise_error
    expect { ISO8601::Time.new('T103012+04') }.to_not raise_error
    expect { ISO8601::Time.new('T10:30:12-00:00') }.to_not raise_error
    expect { ISO8601::Time.new('T16:26:10,5Z') }.to_not raise_error
  end

  context 'reduced patterns' do
    it "should parse correctly reduced times" do
      reduced_time = ISO8601::Time.new('T101112Z')
      reduced_time.hour.should == 10
      reduced_time.minute.should == 11
      reduced_time.second.should == 12
    end
  end

  it "should return each atomic value" do
    dt = ISO8601::Time.new('T12:02:01+04:00', ::Date.parse('2010-05-09'))
    dt.hour.should == 12
    dt.minute.should == 2
    dt.second.should == 1
    dt.zone.should == '+04:00'
  end

  it "should respond to delegated casting methods" do
    dt = ISO8601::Time.new('T10:09:08Z')
    dt.should respond_to(:to_s, :to_time, :to_date, :to_datetime)
  end

  describe '#+' do
    it "should return the result of the addition" do
      (ISO8601::Time.new('T20:20:20+02:00') + 10).to_s.should == 'T20:20:30+02:00'
      (ISO8601::Time.new('T20:20:20.11+02:00') + 10).to_s.should == 'T20:20:30.11+02:00'
    end
  end

  describe '#-' do
    it "should return the result of the substraction" do
      (ISO8601::Time.new('T20:20:20+01:00') - 10).to_s.should == 'T20:20:10+01:00'
      (ISO8601::Time.new('T20:20:20.11+02:00') - 10).to_s.should == 'T20:20:10.11+02:00'
    end
  end

  describe '#to_a' do
    it "should return an array of atoms" do
      ISO8601::Time.new('T19:29:39Z').to_a.should == [19, 29, 39, '+00:00']
    end
  end

  describe '#atoms' do
    it "should return an array of atoms" do
      ISO8601::Time.new('T19:29:39+04:00').atoms.should == [19, 29, 39, '+04:00']
      ISO8601::Time.new('T19:29:39Z').atoms.should == [19, 29, 39, 'Z']
      ISO8601::Time.new('T19:29:39').atoms.should == [19, 29, 39]
      ISO8601::Time.new('T19:29').atoms.should == [19, 29]
      ISO8601::Time.new('T19').atoms.should == [19]
    end
  end
end
