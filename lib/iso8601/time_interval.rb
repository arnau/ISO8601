module ISO8601
  ##
  # A Time Interval representation.
  # See https://en.wikipedia.org/wiki/ISO_8601#Time_intervals
  #
  # @example
  #     ti = ISO8601::TimeInterval.new('P1MT2H/2014-05-28T19:53Z')
  #     ti.to_f # => 2635200.0
  #     ti2 = ISO8601::TimeInterval.new('2014-05-28T19:53Z/2014-05-28T20:53Z')
  #     ti2.to_f # => 3600.0
  #
  # @example
  #     start_time = ISO8601::DateTime.new('2014-05-28T19:53Z')
  #     end_time = ISO8601::DateTime.new('2014-05-30T19:53Z')
  #     ti = ISO8601::TimeInterval.from_datetimes(start_time, end_time)
  #     ti.to_f # => 172800.0 (Seconds)
  #
  # @example
  #     duration = ISO8601::Duration.new('P1MT2H')
  #     end_time = ISO8601::DateTime.new('2014-05-30T19:53Z')
  #     ti = ISO8601::TimeInterval.from_duration(duration, end_time: end_time)
  #     ti.to_f # => 2635200.0 (Seconds)
  #
  # @example
  #     start_time = ISO8601::DateTime.new('2014-05-30T19:53Z')
  #     duration = ISO8601::Duration.new('P1MT2H', base)
  #     ti = ISO8601::TimeInterval.from_duration(duration, start_time: start_time)
  #     ti.to_f # => 2635200.0 (Seconds)
  #
  class TimeInterval
    include Comparable

    # Define the type of a time
    TYPE_DATETIME = :datetime
    TYPE_DURATION = :duration

    ##
    # Initialize a TimeInterval based on a two ISO8601::DateTime instances.
    #
    # @param [ISO8601::DateTime] start_time An ISO8601::DateTime that represents
    #     start time of the interval.
    # @param [ISO8601::DateTime] end_time An ISO8601::DateTime that represents
    #     end time of the interval.
    #
    # @raise [ArgumentError] If any param is not an instance of ISO8601::DateTime
    #
    def self.from_datetimes(start_time, end_time)
      valid_date_time?(start_time) && valid_date_time?(end_time)

      new("#{start_time}/#{end_time}")
    end

    ##
    # Initialize a TimeInterval based on a ISO8601::Duration. To set a correct
    # time interval, we need a start or end point. This point is sent in second
    # parameter.
    #
    # @param [ISO8601::Duration] duration An ISO8601::Duration that represent
    #     the size of the interval.
    # @param [Hash] time A hash to set the start or end point of the time
    #     interval.  This hash must contain an unique key (start_time or
    #     end_time) and a ISO8601::DateTime as value. For example:
    #       { start_time: iso_8601_datetime }
    #       { end_time: iso_8601_datetime }
    #
    # @raise [ArgumentError] if duration is not an instance of ISO8601::Duration
    # @raise [ArgumentError] if keys of time hash are not valid, or the value is
    #     not an instance of ISO8601::DateTime.
    #
    def self.from_duration(duration, time)
      valid_duration?(duration)
      valid_timehash?(time)
      pattern = pattern_from_duration(duration, time)

      new(pattern)
    end

    ##
    # Initialize a TimeInterval ISO8601 by a pattern. If you initialize it with
    # a duration pattern, the second argument is mandatory because you need to
    # specify an start/end point to calculate the interval.
    #
    # @param [String] pattern This parameter define a full time interval. These
    #     patterns are defined in the ISO8601:
    #         * <start_time>/<end_time>
    #         * <start_time>/<duration>
    #         * <duration>/<end_time>
    #
    # @raise [ISO8601::Errors::UnknownPattern] If given pattern is not a valid
    #     ISO8601 pattern.
    # @raise [ArgumentError] Pattern parameter must be an string
    #
    def initialize(pattern)
      # Check pattern
      fail(ArgumentError, 'The pattern must be an string') unless pattern.is_a?(String)
      fail(ISO8601::Errors::UnknownPattern, pattern) unless pattern.include?('/')

      # It's a valid Pattern, we need to detect the elements
      @pattern = pattern
      time = pattern.split('/')
      # We must check this because if a pattern is empty, this method return an
      # Array of 1 element.
      fail(ISO8601::Errors::UnknownPattern, pattern) if time.size != 2
      @start_time, @start_type = init_time_from_pattern(time.first)
      @end_time, @end_type = init_time_from_pattern(time.last)
      # Check classes of initialized elements
      check_times
    end

    ##
    # Alias of `initialize` to have a closer interface to the core `Time`,
    # `Date` and `DateTime` interfaces.
    def parse(pattern)
      new(pattern)
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
    alias_method :first, :start_time

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
    alias_method :last, :end_time

    ##
    # Return original end time
    #
    # @return [ISO8601::DateTime or ISO8601::Duration] end time
    def original_end_time
      @end_time
    end

    ##
    # Return the pattern that craete the same interval
    #
    # @return [String] The pattern of this interval
    def pattern
      return @pattern if @pattern
      "#{original_start_time}/#{original_end_time}"
    end

    alias_method :to_s, :pattern

    ##
    # Calculate the size of the interval. If some time is a Duration, the
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
    alias_method :size, :to_f
    alias_method :length, :to_f

    ##
    # Checks if the interval is empty.
    #
    # @return [Boolean]
    def empty?
      first == last
    end

    ##
    # Check if a given time is inside the current TimeInterval.
    #
    # @param [#to_time] other DateTime to check if it's
    #   inside the current interval.
    #
    # @raise [ISO8601::Errors::TypeError] if time param is not a compatible
    #   Object.
    #
    # @return [Boolean]
    def include?(other)
      fail(ISO8601::Errors::TypeError, 'The parameter must respond_to #to_time') \
        unless other.respond_to?(:to_time)

      seconds = other.to_time.to_f
      (first.to_f <= seconds && last.to_f >= seconds)
    end

    ##
    # Returns true if the interval is a subset of the given interval.
    #
    # @param [ISO8601::TimeInterval] other a time interval.
    #
    # @raise [ISO8601::Errors::TypeError] if time param is not a compatible
    #   Object.
    #
    # @return [Boolean]
    def subset?(other)
      fail(ISO8601::Errors::TypeError, "The parameter must be an instance of #{self.class}") \
        unless other.is_a?(self.class)

      (first.to_time >= other.first.to_time &&
       last.to_time <= other.last.to_time)
    end

    ##
    # Returns true if the interval is a superset of the given interval.
    #
    # @param [ISO8601::TimeInterval] other a time interval.
    #
    # @raise [ISO8601::Errors::TypeError] if time param is not a compatible
    #   Object.
    #
    # @return [Boolean]
    def superset?(other)
      fail(ISO8601::Errors::TypeError, "The parameter must be an instance of #{self.class}") \
        unless other.is_a?(self.class)

      (first.to_time <= other.last.to_time &&
       last.to_time >= other.last.to_time)
    end

    ##
    # Check if two intervarls intersect.
    #
    # @param [ISO8601::Interval] other Another interval to check if they
    #   intersect.
    #
    # @raise [ISO8601::Errors::TypeError] if the param is not a TimeInterval.
    #
    # @return [Boolean]
    def intersect?(other)
      fail(ISO8601::Errors::TypeError,
           "The parameter must be an instance of #{self.class}") \
        unless other.is_a?(self.class)

      (include?(other.first) || include?(other.last))
    end

    ##
    # Check if two intervarls have no element in common.  This method is the
    # opposite of `#intersect?`.
    #
    # @param [ISO8601::Interval] other Another interval to check if they
    #   intersect.
    #
    # @raise [ISO8601::Errors::TypeError] if the param is not a TimeInterval.
    #
    # @return [Boolean]
    def disjoint?(other)
      !intersect?(other)
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
    def valid_date_time?(time)
      return if time.is_a?(::DateTime) || time.is_a?(ISO8601::DateTime)

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
      fail ISO8601::Errors::UnknownPattern,
           "The pattenr of a time interval can't be <duration>/<duration>"
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
    # Check if the parameter is an instance of Duration class.
    #
    # @param [ISO8601::Duration] duration Duration instance
    #
    # @raise [ArgumentError] If one of parameters is not an instance of
    #   ISO8601::Duration
    def self.valid_duration?(duration)
      # Check the type of parameters
      return true if duration.is_a?(ISO8601::Duration)
      fail(ArgumentError,
           'Duration must be an instance of ISO8601::Duration')
    end

    ##
    # Create the pattern based on a duration and time options.
    #
    # @param [ISO8601::Duration] duration An ISO8601::Duration that represent the
    #     size of the interval.
    # @param [Hash] timehash A hash to set the start or end point of the time interval.
    #     This hash must contain an unique key (start_time or end_time) and a
    #     ISO8601::DateTime as value. For example:
    #       { start_time: iso_8601_datetime }
    #       { end_time: iso_8601_datetime }
    #
    # @raise [ArgumentError] if keys of time hash are not valid, or the value is not
    #     an instance of ISO8601::DateTime
    #
    def self.pattern_from_duration(duration, timehash)
      return "#{timehash[:start_time]}/#{duration}" \
        if timehash.keys.include?(:start_time) && valid_date_time?(timehash[:start_time])

      return "#{duration}/#{timehash[:end_time]}" \
        if timehash.keys.include?(:end_time) && valid_date_time?(timehash[:end_time])
    end

    ##
    # Validates if timehash is a Hash and contains either :start_date or :end_date
    #
    # @param [Hash] timehash A hash to set the start or end point of the time interval.
    #     This hash must contain an unique key (start_time or end_time) and a
    #     ISO8601::DateTime as value. For example:
    #       { start_time: iso_8601_datetime }
    #       { end_time: iso_8601_datetime }
    def self.valid_timehash?(timehash)
      fail(ArgumentError, 'Timehash parameter must be a Hash') \
        unless timehash.is_a?(Hash)

      fail(ArgumentError, 'Timehash parameter must have only one key') \
        unless timehash.keys.length == 1

      fail(ArgumentError,
           'You must specify an start_time or end_time in second parameter') \
        unless timehash.keys.include?(:start_time) || timehash.keys.include?(:end_time)
    end

    ##
    # Check two parameters are an instance of DateTime class.
    #
    # @param [ISO8601::DateTime] time DateTime instance
    #
    # @raise [ArgumentError] If time parameters is not an instance of
    #   ISO8601::DateTime
    #
    def self.valid_date_time?(time)
      # Check the type of parameters
      return true if time.is_a?(ISO8601::DateTime)
      fail(ArgumentError,
           'Start time and End time must be an instance of ISO8601::DateTime')
    end
  end
end
