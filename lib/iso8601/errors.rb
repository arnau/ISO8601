# encoding: utf-8

module ISO8601

  # Contains all ISO8601-specific errors.
  module Errors

    # Error that is raised when unknown pattern is parsed.
    class UnknownPattern < ::StandardError
      def initialize(pattern)
        super("The pattern “#{pattern}” is not allowed in this implementation of ISO8601.")
      end
    end
    class RangeError < ::StandardError
      def initialize(pattern)
        super("“#{pattern}” is out of range")
      end
    end
    class DurationError < ::StandardError
      def initialize(duration)
        super("Unexpected type of duration “#{duration}”.")
      end
    end
    class DurationBaseError < ISO8601::Errors::DurationError
      def initialize(duration)
        super("Wrong base for #{duration} duration.")
      end
    end
  end
end
