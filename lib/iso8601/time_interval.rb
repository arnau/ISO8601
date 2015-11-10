module ISO8601
  ##
  # A Time Interval representation.
  # See https://en.wikipedia.org/wiki/ISO_8601#Time_intervals
  #
  # @example
  #     start_time = ISO8601::DateTime.new('2014-05-28T19:53Z')
  #     end_time = ISO8601::DateTime.new('2014-05-30T19:53Z')
  #     ti = ISO8601::TimeInterval.new(start_time, end_time)
  #     ti.size # => 172800.0 (Seconds)
  #
  # @example
  #     start_time = ISO8601::Duration.new('P1MT2H')
  #     end_time = ISO8601::DateTime.new('2014-05-30T19:53Z')
  #     ti = ISO8601::TimeInterval.new(start_time, end_time)
  #     ti.size # => 2635200.0 (Seconds)
  #
  # @example
  #     ti = ISO8601::TimeInterval.new('P1MT2H/2014-05-28T19:53Z')
  #     ti.size # => 2635200.0
  #
  class TimeInterval
    # Define the type of a time
    TYPE_DATETIME = :datetime
    TYPE_DURATION = :duration

    attr_reader :pattern

    ##
    # @param [ISO8601::DateTime, ISO8601::Duration, String] pattern This parameter
    #     can define the full interval, based on a pattern or the start time.
    #     If this param is DateTime or Duration, end_time param is required
    # @param [ISO8601::DateTime, ISO8601::Duration] end_time End time of the
    #     interval.
    #
    # @raise [ISO8601::Errors::TypeError] If any param is not an instance of
    #   ISO8601::Duration or ISO8601::DateTime
    def initialize(pattern, end_time = nil)
      if pattern.is_a? String
        # Check the pattern
        fail(ISO8601::Errors::UnknownPattern, pattern) unless pattern.include?('/')
        # It's a valid Pattern, we need to detect the elements
        @pattern = pattern
        time = pattern.split('/')
        # We must check this because if a pattern is empty, this method return an
        # Array of 1 element.
        fail(ISO8601::Errors::UnknownPattern, pattern) if time.size != 2
        @start_time, @start_type = init_time_from_pattern(time.first)
        @end_time, @end_type = init_time_from_pattern(time.last)
      else
        fail(ArgumentError,
             'A second parameter is required when the first parameter is a '\
             'ISO8601::DateTime or ISO8601::Duration') if end_time.nil?
        @start_time, @start_type = init_time_from_object(pattern)
        @end_time, @end_type = init_time_from_object(end_time)
      end
      # Check classes of initialized elements
      check_times
    end

    ##
    # Calculate and return the start time of the interval
    #
    # @return [ISO8601::DateTime] start time
    def start_time
      return @start_time unless start_duration?
      # Calculate start_time
      @end_time - @start_time.to_seconds
    end

    ##
    # Return original start time
    #
    # @return [ISO8601::DateTime or ISO8601::Duration] start time
    def original_start_time
      @start_time
    end

    ##
    # Calculate and return the end time of the interval
    #
    # @return [ISO8601::DateTime] end time
    def end_time
      return @end_time unless end_duration?
      # Calculate start_time
      @start_time + @end_time.to_seconds
    end

    ##
    # Return original end time
    #
    # @return [ISO8601::DateTime or ISO8601::Duration] end time
    def original_end_time
      @end_time
    end

    ##
    # Calculate the size of the interval. If asome time is a Duration, the
    # size of the Interval is the number of seconds of the interval.
    #
    # @return [Float] Size of the interval in seconds
    def size
      if start_duration?
        @start_time.to_f
      elsif end_duration?
        @end_time.to_f
      else
        # We must calculate the size based on Time interval
        @end_time.to_time.to_f - @start_time.to_time.to_f
      end
    end

    private

    ##
    # Check if the start time is a duration
    #
    # @return [boolean] True if the start_time is a Duration
    def start_duration?
      @start_type == TYPE_DURATION
    end

    ##
    # Check if the end time is a duration
    #
    # @return [boolean] True if the end_time is a Duration
    def end_duration?
      @end_type == TYPE_DURATION
    end

    ##
    # Check if start_time and end_time are Durations. Only one of these elements
    # can be a Duration
    #
    # @raise [ISO8601::Errors::TypeError] If start_time and end_time are durations
    def check_times
      return unless start_duration? && end_duration?
      fail ISO8601::Errors::TypeError, 'Only one time (start time or end time) can be a duration'
    end

    ##
    # Initialize time and type based of a given pattern. The pattern must
    # coincide with a Duration or DateTime ISO8601 format.
    #
    # @param [ISO8601::DateTime, ISO8601::Duration] time String with pattern
    #
    # @raise [ISO8601::Errors::UnknownPattern] If the given pattern is not valid
    #   String of ISO8601 Duration or DateTime
    #
    # @return [Array] Array with two elements: time and type (:duration or :datetime)
    def init_time_from_pattern(time)
      if time.start_with?('P')
        # Duration
        parsed_time = ISO8601::Duration.new(time)
        type = TYPE_DURATION
      else
        # DateTime
        parsed_time = ISO8601::DateTime.new(time)
        type = TYPE_DATETIME
      end
      # Return values
      [parsed_time, type]
    end

    ##
    # Check the class of given time. It must be ISO8601::DateTime or
    # ISO8601::Duration
    #
    # @param [ISO8601::DateTime, ISO8601::Duration] time Given time
    #
    # @raise [ISO8601::Errors::TypeError] If time param is not an instance of
    #   ISO8601::Duration or ISO8601::DateTime
    #
    # @return [Array] Array with two elements: time and type (:duration or :datetime)
    def init_time_from_object(time)
      # Check the type of time
      if time.is_a? ISO8601::DateTime
        type = TYPE_DATETIME
      elsif time.is_a? ISO8601::Duration
        type = TYPE_DURATION
      else
        # Not valid type
        fail ISO8601::Errors::TypeError, time
      end
      # Return values
      [time, type]
    end
  end
end
