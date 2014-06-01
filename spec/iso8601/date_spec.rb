require 'spec_helper'

describe ISO8601::Date do
  it "should raise an error for any unknown pattern" do
    expect { ISO8601::Date.new('2') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Date.new('20') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Date.new('201') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Date.new('2010-') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Date.new('2010-') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Date.new('20-05') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Date.new('2010-0') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Date.new('2010-0-09') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Date.new('2010-1-09') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Date.new('201001-09') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::Date.new('201-0109') }.to raise_error(ISO8601::Errors::UnknownPattern)
  end

  it "should raise an error for a correct pattern but an invalid date" do
    expect { ISO8601::Date.new('2010-01-32') }.to raise_error(ArgumentError)
    expect { ISO8601::Date.new('2010-02-30') }.to raise_error(ArgumentError)
    expect { ISO8601::Date.new('2010-13-30') }.to raise_error(ArgumentError)
  end

  it "should parse any allowed pattern" do
    expect { ISO8601::Date.new('2010') }.to_not raise_error
    expect { ISO8601::Date.new('2010-05') }.to_not raise_error
    expect { ISO8601::Date.new('2010-05-09') }.to_not raise_error
    expect { ISO8601::Date.new('2014-001') }.to_not raise_error
    expect { ISO8601::Date.new('2014121') }.to_not raise_error
  end

  context 'reduced patterns' do
    it "should parse correctly reduced dates" do
      reduced_date = ISO8601::Date.new('20100509')
      reduced_date.year.should == 2010
      reduced_date.month.should == 5
      reduced_date.day.should == 9
    end
  end

  it "should return the right sign for the given year" do
    ISO8601::Date.new('-2014-05-31').year.should == -2014
    ISO8601::Date.new('+2014-05-31').year.should == 2014
  end

  it "should respond to delegated casting methods" do
    dt = ISO8601::Date.new('2014-12-11')
    dt.should respond_to(:to_s, :to_time, :to_date, :to_datetime)
  end

  describe '#+' do
    it "should return the result of the addition" do
      (ISO8601::Date.new('2012-07-07') + 7).to_s.should == '2012-07-14'
    end
  end

  describe '#-' do
    it "should return the result of the substraction" do
      (ISO8601::Date.new('2012-07-07') - 7).to_s.should == '2012-06-30'
    end
  end

  describe '#to_a' do
    it "should return an array of atoms" do
      dt = ISO8601::Date.new('2014-05-31').to_a
      dt.should be_kind_of(Array)
      dt.should == [2014, 5, 31]
    end
  end

  describe '#to_atom' do
    it "should return an array of original atoms" do
      ISO8601::Date.new('2014-05-02').to_atoms.should == [2014, 5, 2]
      ISO8601::Date.new('2014-05').to_atoms.should == [2014, 5]
      ISO8601::Date.new('2014').to_atoms.should == [2014]
    end
  end
end
