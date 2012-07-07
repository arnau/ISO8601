require 'spec_helper'

describe ISO8601::Atom do
  it "should raise a TypeError when receives anything but a Numeric value" do
    expect { ISO8601::Atom.new('1') }.to raise_error(TypeError)
    expect { ISO8601::Atom.new(true) }.to raise_error(TypeError)
    expect { ISO8601::Atom.new(-1.1) }.to_not raise_error(TypeError)
    expect { ISO8601::Atom.new(-1) }.to_not raise_error(TypeError)
    expect { ISO8601::Atom.new(0) }.to_not raise_error(TypeError)
    expect { ISO8601::Atom.new(1) }.to_not raise_error(TypeError)
    expect { ISO8601::Atom.new(1.1) }.to_not raise_error(TypeError)
  end
  it "should raise a TypeError when receives anything but a ISO8601::DateTime instance or nil" do
    expect { ISO8601::Atom.new(1, ISO8601::DateTime.new('2012-07-07')) }.to_not raise_error(TypeError)
    expect { ISO8601::Atom.new(1, nil) }.to_not raise_error(TypeError)
    expect { ISO8601::Atom.new(1, true) }.to raise_error(TypeError)
    expect { ISO8601::Atom.new(1, 'foo') }.to raise_error(TypeError)
    expect { ISO8601::Atom.new(1, 10) }.to raise_error(TypeError)
  end
  it "should create a new atom" do
    ISO8601::Atom.new(-1).should be_an_instance_of(ISO8601::Atom)
  end

  describe '#to_i' do
    it "should return an integer" do
      ISO8601::Atom.new(1).to_i.should be_a_kind_of(Integer)
      ISO8601::Atom.new(1.0).to_i.should be_a_kind_of(Integer)
    end
    it "should return the integer part of the given number" do
      n = 1.0
      ISO8601::Atom.new(n).to_i.should == n.to_i
    end
  end
end

describe ISO8601::Years do
  describe '#factor' do
    it "should return the Year factor" do
      ISO8601::Years.new(2).factor.should == 31536000
      ISO8601::Years.new(1).factor.should == 31536000
    end
    it "should return the Year factor for a common year" do
      ISO8601::Years.new(1, ISO8601::DateTime.new("2010-01-01")).factor.should == 31536000
    end
    it "should return the Year factor for a leap year" do
      ISO8601::Years.new(1, ISO8601::DateTime.new("2000-01-01")).factor.should == 31622400
    end
  end

  describe '#to_seconds' do
    it "should return the amount of seconds" do
      ISO8601::Years.new(2).to_seconds.should == 63072000
      ISO8601::Years.new(-2).to_seconds.should == -63072000
    end
    it "should return the amount of seconds for a common year" do
      base = ISO8601::DateTime.new('2010-01-01')
      ISO8601::Years.new(2, base).to_seconds.should == 63072000
      ISO8601::Years.new(12, base).to_seconds.should == 378691200
    end
    it "should return the amount of seconds for a leap year" do
      base = ISO8601::DateTime.new('2000-01-01')
      ISO8601::Years.new(2, base).to_seconds.should == 63158400
      ISO8601::Years.new(15, base).to_seconds.should == 473385600
    end
  end
end

