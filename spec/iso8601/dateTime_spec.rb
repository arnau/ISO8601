# encoding: utf-8

require 'spec_helper'

describe ISO8601::DateTime do
  it "should raise a ISO8601::Errors::UnknownPattern for any unknown pattern" do
    expect { ISO8601::DateTime.new('2') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::DateTime.new('201') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::DateTime.new('2010-') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::DateTime.new('2010-') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::DateTime.new('20-05') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::DateTime.new('2010-0') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::DateTime.new('2010-0-09') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::DateTime.new('2010-1-09') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::DateTime.new('201001-09') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::DateTime.new('201-0109') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::DateTime.new('2010-05-09T103012+0400') }.to raise_error(ISO8601::Errors::UnknownPattern)
    expect { ISO8601::DateTime.new('20100509T10:30:12+04:00') }.to raise_error(ISO8601::Errors::UnknownPattern)
  end
end
