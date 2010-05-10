module ISO8601

  # Contains all ISO8601-specific errors.
  module Errors
    
    # Error that is raised when unknown pattern is parsed.
    class UnknownPattern < ::StandardError
      def initialize(pattern)
        super("The pattern “#{pattern}” is not allowed in this implementation of ISO8601.")
      end
    end
  end
end