require 'spec_helper'

RSpec.describe ISO8601::Atom do
  it "should raise a TypeError when receives anything but a Numeric value" do
    expect { ISO8601::Atom.new('1') }.to raise_error(ISO8601::Errors::TypeError)
    expect { ISO8601::Atom.new(true) }.to raise_error(ISO8601::Errors::TypeError)
    expect { ISO8601::Atom.new(-1.1) }.to_not raise_error
    expect { ISO8601::Atom.new(-1) }.to_not raise_error
    expect { ISO8601::Atom.new(0) }.to_not raise_error
    expect { ISO8601::Atom.new(1) }.to_not raise_error
    expect { ISO8601::Atom.new(1.1) }.to_not raise_error
  end
  it "should raise a TypeError when receives anything but a ISO8601::DateTime instance or nil" do
    expect { ISO8601::Atom.new(1, ISO8601::DateTime.new('2012-07-07')) }.to_not raise_error
    expect { ISO8601::Atom.new(1, nil) }.to_not raise_error
    expect { ISO8601::Atom.new(1, true) }.to raise_error(ISO8601::Errors::TypeError)
    expect { ISO8601::Atom.new(1, 'foo') }.to raise_error(ISO8601::Errors::TypeError)
    expect { ISO8601::Atom.new(1, 10) }.to raise_error(ISO8601::Errors::TypeError)
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
  describe '#<=>' do
    it "should be comparable to atoms of the same type" do
      expect(ISO8601::Atom.new(1) <=> ISO8601::Atom.new(1)).to eq(0)
      expect(ISO8601::Atom.new(1) <=> ISO8601::Atom.new(2)).to eq(-1)
      expect(ISO8601::Atom.new(2) <=> ISO8601::Atom.new(1)).to eq(1)
      expect(ISO8601::Years.new(2) > ISO8601::Years.new(1)).to be_truthy
    end
    it "should not be comparable to different types" do
      expect(ISO8601::Years.new(1) <=> ISO8601::Months.new(1)).to be_nil
      expect { ISO8601::Years.new(1) <= 1 }.to raise_error(ArgumentError)
      expect { ISO8601::Years.new(2) > 1 }.to raise_error(ArgumentError)
    end
    it "should be ordered" do
      expect(ISO8601::Atom.new(5) > ISO8601::Atom.new(4)).to be_truthy
      expect(ISO8601::Atom.new(5) < ISO8601::Atom.new(4)).to be_falsy
    end
  end
end
