module ISO8601
  ##
  # A Time Interval representation.
  # See https://en.wikipedia.org/wiki/ISO_8601#Time_intervals
  #
  # @example
  #     start_time = ISO8601::DateTime.new('2014-05-28T19:53Z')
  #     end_time = ISO8601::DateTime.new('2014-05-30T19:53Z')
  #     ti = ISO8601::TimeInterval.new(start_time, end_time)
  #     ti.to_f # => 172800.0 (Seconds)
  #
  # @example
  #     start_time = ISO8601::Duration.new('P1MT2H')
  #     end_time = ISO8601::DateTime.new('2014-05-30T19:53Z')
  #     ti = ISO8601::TimeInterval.new(start_time, end_time)
  #     ti.to_f # => 2635200.0 (Seconds)
  #
  # @example
  #     ti = ISO8601::TimeInterval.new('P1MT2H/2014-05-28T19:53Z')
  #     ti.to_f # => 2635200.0
  #
  # @example
  #     base = ISO8601::DateTime.new('2014-05-30T19:53Z')
  #     duration = ISO8601::Duration.new('P1MT2H', base)
  #     ti = ISO8601::TimeInterval.new(start_time, end_time)
  #     ti.to_f # => 2635200.0 (Seconds)
  #
  class TimeInterval
    include Comparable

    # Define the type of a time
    TYPE_DATETIME = :datetime
    TYPE_DURATION = :duration

    ##
    # @param [ISO8601::DateTime, ISO8601::Duration, String] pattern This parameter
    #     can define the full interval, based on a pattern or the start time.
    #     If this param is DateTime or Duration, end_time param is required
    # @param [ISO8601::DateTime, ISO8601::Duration] end_time End time of the
    #     interval.
    #
    # @raise [ISO8601::Errors::TypeError] If any param is not an instance of
    #   ISO8601::Duration or ISO8601::DateTime
    # @raise [ArgumentError] If the first element is an ISO8601::Duration/DateTime and
    #   second element is nil or first parameter is an ISO8601::Duration and it's base
    #   is nil when second parameter is nil too.
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
      elsif pattern.is_a?(ISO8601::Duration) && end_time.nil?
        @start_time, @start_type = init_time_from_duration(pattern)
        pattern.base = nil
        @end_time = pattern
        @end_type = TYPE_DURATION
      else
        # Initialize with two objects
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
    # Return the pattern that crete the same interval
    #
    # @return [String] The pattern of this interval
    def pattern
      return @pattern if @pattern
      "#{original_start_time}/#{original_end_time}"
    end

    alias_method :to_s, :pattern

    ##
    # Calculate the size of the interval. If asome time is a Duration, the
    # size of the Interval is the number of seconds of the interval.
    #
    # @return [Float] Size of the interval in seconds
    def to_f
      if start_duration?
        @start_time.to_f
      elsif end_duration?
        @end_time.to_f
      else
        # We must calculate the size based on Time interval
        @end_time.to_time.to_f - @start_time.to_time.to_f
      end
    end

    ##
    # Check if a given time is inside current TimeInterval
    #
    # @param [ISO8601::DateTime, ISO8601::Interval, DateTime] time Object
    #   to check if it's inside the current interval. For a ISO8601::Interval
    #   all the interval must be inside.
    #
    # @raise [ISO8601::Errors::TypeError] if time param is not a compatible Object
    #
    # @return [Boolean]
    def include?(other)
      check_date_time(other)
      if other.is_a?(self.class)
        # Interval
        (start_time.to_f < other.start_time.to_f && other.end_time.to_f < end_time.to_f)
      else
        # DateTime
        time_seconds = other.to_time.to_f
        (start_time.to_f < time_seconds && time_seconds < end_time.to_f)
      end
    end

    ##
    # Check if two intervarls overlap in time
    #
    # @param [ISO8601::Interval] interval Another interval to check if they overlap
    #
    # @raise [ISO8601::Errors::TypeError] if interval param is not a compatible Object
    #
    # @return [Boolean]
    def overlap?(interval)
      check_interval(interval)
      # We check if the start time or end time are inside the interval
      (include?(interval.start_time) || include?(interval.end_time))
    end

    ##
    # @param [ISO8601::TimeInterval] other The contrast to compare against
    #
    # @return [-1, 0, 1]
    def <=>(other)
      return nil unless other.is_a?(self.class)

      to_f <=> other.to_f
    end

    ##
    # Compare the TimeIntervals based on the Hash of the objects
    #
    # @param [ISO8601::TimeInterval] other TimeInterval instance
    #
    # @return [Boolean]
    def eql?(other)
      (hash == other.hash)
    end

    ##
    # @return [Fixnum]
    def hash
      [@start_time.hash, @end_time.hash].hash
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
    # Check if the given argument is a instance of ISO8601::DateTime,
    # ISO8601::TimeInterval or DateTime.
    #
    # @raise [ISO8601::Errors::TypeError]
    def check_date_time(time)
      return if time.is_a?(::DateTime) || time.is_a?(ISO8601::DateTime) ||
                time.is_a?(self.class)
      fail(ISO8601::Errors::TypeError,
           'Parameter must be an instance of ISO8601::DateTime, ISO8601::TimeInterval or DateTime')
    end

    ##
    # Check if the given argument is a instance of ISO8601::TimeInterval
    #
    # @raise [ISO8601::Errors::TypeError]
    def check_interval(interval)
      return if interval.is_a?(self.class)
      fail(ISO8601::Errors::TypeError,
           'Parameter must be an instance of ISO8601::TimeInterval')
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
    # Initialize time and type based on a Duration.
    #
    # @param [ISO8601::Duration] time String with pattern
    #
    # @raise [ArgumentError] If the base of time is nil
    #
    # @return [Array] Array with two elements: time and type (:duration or :datetime)
    def init_time_from_duration(duration)
      # The duration must have a base
      fail(ArgumentError,
           'Duration must include a Base to calculate the interval') if duration.base.nil?
      parsed_time = duration.base
      type = TYPE_DATETIME
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

    ##
    # Fetch the number of seconds of another element.
    #
    # @param [ISO8601::TimeInterval, Numeric] other Instance of a class to fetch
    #   seconds.
    #
    # @raise [ISO8601::Errors::TypeError] If other param is not an instance of
    #   ISO8601::TimeInterval or Numeric classes
    #
    # @return [Float] Number of seconds of other param Object
    #
    def fetch_seconds(other)
      if other.is_a?(self.class) || other.is_a?(Numeric)
        other.to_f
      else
        fail ISO8601::Errors::TypeError, other
      end
    end
  end
end
