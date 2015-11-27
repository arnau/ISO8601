require 'spec_helper'

RSpec.describe ISO8601::Hours do
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
