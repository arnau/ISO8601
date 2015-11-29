require 'spec_helper'

RSpec.describe ISO8601::Months do
  let(:common_year) { ISO8601::DateTime.new('2010-02-01') }
  let(:leap_year) { ISO8601::DateTime.new('2000-02-01') }

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
      expect(ISO8601::Months.new(12, ISO8601::DateTime.new('2000-02-01')).to_seconds).to eq(ISO8601::Years.new(1).to_seconds(leap_year))
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
