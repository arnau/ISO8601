# encoding: utf-8

require 'spec_helper'

describe ISO8601::Duration do
  it "should raise a ISO8601::Errors::UnknownPattern for any unknown pattern" do
    expect { ISO8601::Duration.new('P') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('PT') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('P1YT') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('T') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('PW') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('P1Y1W') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('~P1Y') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('.P1Y') }.to raise_error(ISO8601::Errors::UnknownPattern)
  end
  it "should parse any allowed pattern" do
    expect { ISO8601::Duration.new('P1Y') }.to_not raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('P1Y1M') }.to_not raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('P1Y1M1D') }.to_not raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('P1Y1M1DT1H') }.to_not raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('P1Y1M1DT1H1M') }.to_not raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('P1Y1M1DT1H1M1S') }.to_not raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('P1Y1M1DT1H1M1.0S') }.to_not raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('P1W') }.to_not raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('+P1Y') }.to_not raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Duration.new('-P1Y') }.to_not raise_error(ISO8601::Errors::UnknownPattern)
  end
  it "should raise a TypeError when the base is not a ISO8601::DateTime" do
    expect { ISO8601::Duration.new('P1Y1M1DT1H1M1S', ISO8601::DateTime.new('2010-01-01')) }.to_not raise_error(TypeError)
    expect { ISO8601::Duration.new('P1Y1M1DT1H1M1S', '2010-01-01') }.to raise_error(TypeError)
    expect { ISO8601::Duration.new('P1Y1M1DT1H1M1S', 2010) }.to raise_error(TypeError)
    expect {
      d = ISO8601::Duration.new('P1Y1M1DT1H1M1S', ISO8601::DateTime.new('2010-01-01'))
      d.base = 2012
    }.to raise_error(TypeError)
  end

  describe '#base' do
    it "should return the base datetime" do
      dt = ISO8601::DateTime.new('2010-01-01')
      dt2 = ISO8601::DateTime.new('2012-01-01')
      ISO8601::Duration.new('P1Y1M1DT1H1M1S').base.should be_an_instance_of(NilClass)
      ISO8601::Duration.new('P1Y1M1DT1H1M1S', dt).base.should be_an_instance_of(ISO8601::DateTime)
      ISO8601::Duration.new('P1Y1M1DT1H1M1S', dt).base.should equal(dt)
      d = ISO8601::Duration.new('P1Y1M1DT1H1M1S', dt).base = dt2
      d.should equal(dt2)
    end
  end

  describe '#to_s' do
    it "should return the duration as a string" do
      ISO8601::Duration.new('P1Y1M1DT1H1M1S').to_s.should == 'P1Y1M1DT1H1M1S'
    end
  end

  describe '#+' do
    it "should return the result of the addition" do
      (ISO8601::Duration.new('P1Y1M1DT1H1M1S') + ISO8601::Duration.new('PT10S')).to_s.should == 'P1Y1M1DT1H1M11S'
      (ISO8601::Duration.new('P1Y1M1DT1H1M1S') + ISO8601::Duration.new('PT10S')).should be_an_instance_of(ISO8601::Duration)
    end
  end

  describe '#-' do
    it "should return the result of the substraction" do
      (ISO8601::Duration.new('P1Y1M1DT1H1M1S') - ISO8601::Duration.new('PT10S')).should be_an_instance_of(ISO8601::Duration)
      (ISO8601::Duration.new('P1Y1M1DT1H1M11S') - ISO8601::Duration.new('PT10S')).to_s.should == 'P1Y1M1DT1H1M1S'
      (ISO8601::Duration.new('PT12S') - ISO8601::Duration.new('PT12S')).to_s.should == 'PT0S'
      (ISO8601::Duration.new('PT12S') - ISO8601::Duration.new('PT1S')).to_s.should == 'PT11S'
      (ISO8601::Duration.new('PT1S') - ISO8601::Duration.new('PT12S')).to_s.should == '-PT11S'
    end
  end
end
