require 'spec_helper'

RSpec.describe ISO8601::Minutes do
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
    it "should respond to #hash" do
      expect(ISO8601::Minutes.new(3)).to respond_to(:hash)
    end

    it "should build hash identity by value" do
      expect(ISO8601::Minutes.new(3).hash).to eq(ISO8601::Minutes.new(3).hash)
    end
  end
end
