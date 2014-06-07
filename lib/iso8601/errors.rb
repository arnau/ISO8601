# encoding: utf-8

module ISO8601
  ##
  # Contains all ISO8601-specific errors.
  module Errors
    ##
    # Raised when the given pattern doesn't fit as ISO 8601 parser.
    class UnknownPattern < ::StandardError
      def initialize(pattern)
        super("The pattern “#{pattern}” is not allowed in this implementation of ISO8601.")
      end
    end
    ##
    # Raised when the given date is valid but out of range.
    class RangeError < ::StandardError
      def initialize(pattern)
        super("“#{pattern}” is out of range")
      end
    end
    ##
    # Raise when the base is not suitable.
    class DurationBaseError < ::StandardError
      def initialize(duration)
        super("Wrong base for #{duration} duration.")
      end
    end
  end
end
