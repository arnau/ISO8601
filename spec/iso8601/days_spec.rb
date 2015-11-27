require 'spec_helper'

RSpec.describe ISO8601::Days do
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
