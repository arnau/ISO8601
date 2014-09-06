require 'spec_helper'

RSpec.describe ISO8601::Atom do
  it "should raise a TypeError when receives anything but a Numeric value" do
    expect { ISO8601::Atom.new('1') }.to raise_error
    expect { ISO8601::Atom.new(true) }.to raise_error
    expect { ISO8601::Atom.new(-1.1) }.to_not raise_error
    expect { ISO8601::Atom.new(-1) }.to_not raise_error
    expect { ISO8601::Atom.new(0) }.to_not raise_error
    expect { ISO8601::Atom.new(1) }.to_not raise_error
    expect { ISO8601::Atom.new(1.1) }.to_not raise_error
  end
  it "should raise a TypeError when receives anything but a ISO8601::DateTime instance or nil" do
    expect { ISO8601::Atom.new(1, ISO8601::DateTime.new('2012-07-07')) }.to_not raise_error
    expect { ISO8601::Atom.new(1, nil) }.to_not raise_error
    expect { ISO8601::Atom.new(1, true) }.to raise_error
    expect { ISO8601::Atom.new(1, 'foo') }.to raise_error
    expect { ISO8601::Atom.new(1, 10) }.to raise_error
  end
  it "should create a new atom" do
    expect(ISO8601::Atom.new(-1)).to be_an_instance_of(ISO8601::Atom)
  end
  describe '#to_i' do
    it "should return an integer" do
      expect(ISO8601::Atom.new(1).to_i).to be_a_kind_of(Integer)
      expect(ISO8601::Atom.new(1.0).to_i).to be_a_kind_of(Integer)
    end
    it "should return the integer part of the given number" do
      expect(ISO8601::Atom.new(1.0).to_i).to eq(1.0.to_i)
    end
  end
  describe '#to_f' do
    it "should return a float" do
      expect(ISO8601::Atom.new(1).to_f).to be_a_kind_of(Float)
      expect(ISO8601::Atom.new(1.0).to_f).to be_a_kind_of(Float)
    end
  end
  describe '#value' do
    it "should return the simplest value representation" do
      expect(ISO8601::Atom.new(1).value).to eq(1)
      expect(ISO8601::Atom.new(1.0).value).to eq(1)
      expect(ISO8601::Atom.new(1.1).value).to eq(1.1)
    end
  end
  describe '#factor' do
    it "should raise a NotImplementedError" do
      expect { ISO8601::Atom.new(1).factor }.to raise_error(NotImplementedError)
    end
  end
end

describe ISO8601::Years do
  describe '#factor' do
    it "should return the Year factor" do
      expect { ISO8601::Years.new(1).factor }.to_not raise_error
      expect(ISO8601::Years.new(2).factor).to eq(31536000)
      expect(ISO8601::Years.new(1).factor).to eq(31536000)
    end
    it "should return the Year factor for a common year" do
      expect(ISO8601::Years.new(1, ISO8601::DateTime.new("2010-01-01")).factor).to eq(31536000)
    end
    it "should return the Year factor for a leap year" do
      expect(ISO8601::Years.new(1, ISO8601::DateTime.new("2000-01-01")).factor).to eq(31622400)
    end
  end

  describe '#to_seconds' do
    it "should return the amount of seconds" do
      expect(ISO8601::Years.new(2).to_seconds).to eq(63072000)
      expect(ISO8601::Years.new(-2).to_seconds).to eq(-63072000)
    end
    it "should return the amount of seconds for a common year" do
      base = ISO8601::DateTime.new('2010-01-01')
      expect(ISO8601::Years.new(2, base).to_seconds).to eq(63072000)
      expect(ISO8601::Years.new(12, base).to_seconds).to eq(378691200)
    end
    it "should return the amount of seconds for a leap year" do
      base = ISO8601::DateTime.new('2000-01-01')
      expect(ISO8601::Years.new(2, base).to_seconds).to eq(63158400)
      expect(ISO8601::Years.new(15, base).to_seconds).to eq(473385600)
    end
  end

  describe '#symbol' do
    it "should return the ISO symbol" do
      expect(ISO8601::Years.new(1)).to respond_to(:symbol)
      expect(ISO8601::Years.new(1).symbol).to eq(:Y)
    end
  end

  describe '#hash' do
    let(:subject) { ISO8601::Years.new(3) }
    it "should respond to #hash" do
      expect(subject).to respond_to(:hash)
    end
    it "should build hash identity by value" do
      contrast = ISO8601::Years.new(3)

      expect(subject.hash == contrast.hash).to be_truthy
    end
  end
end

describe ISO8601::Months do
  describe '#factor' do
    it "should return the Month factor" do
      expect { ISO8601::Months.new(1).factor }.to_not raise_error
      expect(ISO8601::Months.new(2).factor).to eq(2628000)
    end
    it "should return the Month factor for a common year" do
      expect(ISO8601::Months.new(1, ISO8601::DateTime.new('2010-01-01')).factor).to eq(2678400)
    end
    it "should return the Month factor for a leap year" do
      expect(ISO8601::Months.new(1, ISO8601::DateTime.new('2000-01-01')).factor).to eq(2678400)
    end
    it "should return the Month factor based on february for a common year" do
      expect(ISO8601::Months.new(1, ISO8601::DateTime.new('2010-02-01')).factor).to eq(2419200)
    end
    it "should return the Month factor based on february for a leap year" do
      expect(ISO8601::Months.new(1, ISO8601::DateTime.new('2000-02-01')).factor).to eq(2505600)
    end
  end
  describe '#to_seconds' do
    it "should return the amount of seconds" do
      expect(ISO8601::Months.new(2).to_seconds).to eq(5256000)
    end
    it "should return the amount of seconds for a common year" do
      expect(ISO8601::Months.new(2, ISO8601::DateTime.new('2010-01-01')).to_seconds).to eq(5097600)
    end
    it "should return the amount of seconds for a leap year" do
      expect(ISO8601::Months.new(2, ISO8601::DateTime.new('2000-01-01')).to_seconds).to eq(5184000)
    end
    it "should return the amount of seconds based on februrary for a common year" do
      expect(ISO8601::Months.new(2, ISO8601::DateTime.new('2010-02-01')).to_seconds).to eq(5097600)
    end
    it "should return the amount of seconds based on february for a leap year" do
      expect(ISO8601::Months.new(2, ISO8601::DateTime.new('2000-02-01')).to_seconds).to eq(5184000)
      expect(ISO8601::Months.new(12, ISO8601::DateTime.new('2000-02-01')).to_seconds).to eq(31622400)
      expect(ISO8601::Months.new(12, ISO8601::DateTime.new('2000-02-01')).to_seconds).to eq(ISO8601::Years.new(1, ISO8601::DateTime.new("2000-02-01")).to_seconds)
    end
  end
  describe '#symbol' do
    it "should return the ISO symbol" do
      expect(ISO8601::Months.new(1)).to respond_to(:symbol)
      expect(ISO8601::Months.new(1).symbol).to eq(:M)
    end
  end

  describe '#hash' do
    let(:subject) { ISO8601::Months.new(3) }
    it "should respond to #hash" do
      expect(subject).to respond_to(:hash)
    end
    it "should build hash identity by value" do
      contrast = ISO8601::Months.new(3)

      expect(subject.hash == contrast.hash).to be_truthy
    end
  end
end

describe ISO8601::Weeks do
  describe '#factor' do
    it "should return the Week factor" do
      expect(ISO8601::Weeks.new(2).factor).to eq(604800)
    end
  end
  describe '#to_seconds' do
    it "should return the amount of seconds" do
      expect(ISO8601::Weeks.new(2).to_seconds).to eq(1209600)
      expect(ISO8601::Weeks.new(-2).to_seconds).to eq(-1209600)
    end
  end
  describe '#symbol' do
    it "should return the ISO symbol" do
      expect(ISO8601::Weeks.new(1)).to respond_to(:symbol)
      expect(ISO8601::Weeks.new(1).symbol).to eq(:W)
    end
  end

  describe '#hash' do
    let(:subject) { ISO8601::Weeks.new(3) }
    it "should respond to #hash" do
      expect(subject).to respond_to(:hash)
    end
    it "should build hash identity by value" do
      contrast = ISO8601::Weeks.new(3)

      expect(subject.hash == contrast.hash).to be_truthy
    end
  end
end

describe ISO8601::Days do
  describe '#factor' do
    it "should return the Day factor" do
      expect(ISO8601::Days.new(2).factor).to eq(86400)
    end
    it "should return the amount of seconds" do
      expect(ISO8601::Days.new(2).to_seconds).to eq(172800)
      expect(ISO8601::Days.new(-2).to_seconds).to eq(-172800)
    end
  end
  describe '#symbol' do
    it "should return the ISO symbol" do
      expect(ISO8601::Days.new(1)).to respond_to(:symbol)
      expect(ISO8601::Days.new(1).symbol).to eq(:D)
    end
  end

  describe '#hash' do
    let(:subject) { ISO8601::Days.new(3) }
    it "should respond to #hash" do
      expect(subject).to respond_to(:hash)
    end
    it "should build hash identity by value" do
      contrast = ISO8601::Days.new(3)

      expect(subject.hash == contrast.hash).to be_truthy
    end
  end
end

describe ISO8601::Hours do
  describe '#factor' do
    it "should return the Hour factor" do
      expect(ISO8601::Hours.new(2).factor).to eq(3600)
    end
    it "should return the amount of seconds" do
      expect(ISO8601::Hours.new(2).to_seconds).to eq(7200)
      expect(ISO8601::Hours.new(-2).to_seconds).to eq(-7200)
    end
  end
  describe '#symbol' do
    it "should return the ISO symbol" do
      expect(ISO8601::Hours.new(1)).to respond_to(:symbol)
      expect(ISO8601::Hours.new(1).symbol).to eq(:H)
    end
  end

  describe '#hash' do
    let(:subject) { ISO8601::Hours.new(3) }
    it "should respond to #hash" do
      expect(subject).to respond_to(:hash)
    end
    it "should build hash identity by value" do
      contrast = ISO8601::Hours.new(3)

      expect(subject.hash == contrast.hash).to be_truthy
    end
  end
end

describe ISO8601::Minutes do
  describe '#factor' do
    it "should return the Minute factor" do
      expect(ISO8601::Minutes.new(2).factor).to eq(60)
    end
    it "should return the amount of seconds" do
      expect(ISO8601::Minutes.new(2).to_seconds).to eq(120)
      expect(ISO8601::Minutes.new(-2).to_seconds).to eq(-120)
    end
  end
  describe '#symbol' do
    it "should return the ISO symbol" do
      expect(ISO8601::Minutes.new(1)).to respond_to(:symbol)
      expect(ISO8601::Minutes.new(1).symbol).to eq(:M)
    end
  end

  describe '#hash' do
    let(:subject) { ISO8601::Minutes.new(3) }
    it "should respond to #hash" do
      expect(subject).to respond_to(:hash)
    end
    it "should build hash identity by value" do
      contrast = ISO8601::Minutes.new(3)

      expect(subject.hash == contrast.hash).to be_truthy
    end
  end
end

describe ISO8601::Seconds do
  describe '#factor' do
    it "should return the Second factor" do
      expect(ISO8601::Seconds.new(2).factor).to eq(1)
    end
    it "should return the amount of seconds" do
      expect(ISO8601::Seconds.new(2).to_seconds).to eq(2)
      expect(ISO8601::Seconds.new(-2).to_seconds).to eq(-2)
    end
  end
  describe '#symbol' do
    it "should return the ISO symbol" do
      expect(ISO8601::Seconds.new(1)).to respond_to(:symbol)
      expect(ISO8601::Seconds.new(1).symbol).to eq(:S)
    end
  end

  describe '#hash' do
    let(:subject) { ISO8601::Seconds.new(3) }
    it "should respond to #hash" do
      expect(subject).to respond_to(:hash)
    end
    it "should build hash identity by value" do
      contrast = ISO8601::Seconds.new(3)

      expect(subject.hash == contrast.hash).to be_truthy
    end
  end
end
