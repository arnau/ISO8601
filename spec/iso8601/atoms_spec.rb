require 'spec_helper'

describe ISO8601::Atom do
  it "should raise a TypeError" do
    expect { ISO8601::Atom.new('1') }.to raise_error(TypeError)
    expect { ISO8601::Atom.new(true) }.to raise_error(TypeError)
    expect { ISO8601::Atom.new(-1.1) }.to_not raise_error(TypeError)
    expect { ISO8601::Atom.new(-1) }.to_not raise_error(TypeError)
    expect { ISO8601::Atom.new(0) }.to_not raise_error(TypeError)
    expect { ISO8601::Atom.new(1) }.to_not raise_error(TypeError)
    expect { ISO8601::Atom.new(1.1) }.to_not raise_error(TypeError)
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
