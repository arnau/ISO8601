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
      fail(ArgumentError, 'The pattern must be an string') unless pattern.is_a?(String)
      fail(ISO8601::Errors::UnknownPattern, pattern) unless pattern.include?('/')

      @pattern = pattern
      subpatterns = pattern.split('/')

      fail(ISO8601::Errors::UnknownPattern, pattern) if subpatterns.size != 2

      @atoms = subpatterns.map { |x| parse_subpattern(x) }
      @first, @last, @size = boundaries(@atoms)
    end

    ##
    # Alias of `initialize` to have a closer interface to the core `Time`,
    # `Date` and `DateTime` interfaces.
    def parse(pattern)
      new(pattern)
    end

    ##
    # The start time (first) of the interval.
    #
    # @return [ISO8601::DateTime] start time
    attr_reader :first

    ##
    # The end time (last) of the interval.
    #
    # @return [ISO8601::DateTime] end time
    attr_reader :last

    ##
    # The pattern for the interval.
    #
    # @return [String] The pattern of this interval
    def pattern
      return @pattern if @pattern

      "#{@atoms.first}/#{@atoms.last}"
    end

    alias_method :to_s, :pattern

    ##
    # The size of the interval. If any bound is a Duration, the
    # size of the interval is the number of seconds of the interval.
    #
    # @return [Float] Size of the interval in seconds
    attr_reader :size
    alias_method :to_f, :size
    alias_method :length, :size

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

      (first.to_time <= other.to_time &&
       last.to_time >= other.to_time)
    end
    alias_method :member?, :include?

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

      other.include?(first) && other.include?(last)
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

      include?(other.first) && include?(other.last)
    end

    ##
    # Check if two intervarls intersect.
    #
    # @param [ISO8601::TimeInterval] other Another interval to check if they
    #   intersect.
    #
    # @raise [ISO8601::Errors::TypeError] if the param is not a TimeInterval.
    #
    # @return [Boolean]
    def intersect?(other)
      fail(ISO8601::Errors::TypeError,
           "The parameter must be an instance of #{self.class}") \
        unless other.is_a?(self.class)

      include?(other.first) || include?(other.last)
    end

    ##
    # Return the intersection between two intervals.
    #
    # @param [ISO8601::TimeInterval] other time interval
    #
    # @raise [ISO8601::Errors::TypeError] if the param is not a TimeInterval.
    #
    # @return [Boolean]
    def intersection(other)
      fail(ISO8601::Errors::IntervalError, "The intervals are disjoint") \
        if disjoint?(other) && other.disjoint?(self)

      return self if subset?(other)
      return other if other.subset?(self)

      a, b = sort_pair(self, other)
      self.class.from_datetimes(b.first, a.last)
    end

    ##
    # Check if two intervarls have no element in common.  This method is the
    # opposite of `#intersect?`.
    #
    # @param [ISO8601::TimeInterval] other Time interval.
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
      @atoms.hash
    end

    private

    def sort_pair(a, b)
      (a.first < b.first) ? [a, b] : [b, a]
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
    # Parses a subpattern to a correct type.
    #
    # @param [String] pattern
    #
    # @return [ISO8601::Duration, ISO8601::DateTime]
    def parse_subpattern(pattern)
      return ISO8601::Duration.new(pattern) if pattern.start_with?('P')

      ISO8601::DateTime.new(pattern)
    end

    ##
    # Calculates the boundaries (first, last) and the size of the interval.
    #
    # @param [Array] atoms The atoms result of parsing the pattern.
    #
    # @return [Array]
    def boundaries(atoms)
      valid_atoms?(atoms)

      if atoms.none? { |x| x.is_a?(ISO8601::Duration) }
        return [atoms.first,
                atoms.last,
                (atoms.last.to_time - atoms.first.to_time)]
      elsif atoms.first.is_a?(ISO8601::Duration)
        seconds = atoms.first.to_seconds(atoms.last)
        return [(atoms.last - seconds),
                atoms.last,
                seconds]
      else
        seconds = atoms.last.to_seconds(atoms.first)
        return [atoms.first,
                (atoms.first + seconds),
                seconds]
      end
    end

    def valid_atoms?(atoms)
      fail(ISO8601::Errors::UnknownPattern,
           "The pattern of a time interval can't be <duration>/<duration>") \
        if atoms.all? { |x| x.is_a?(ISO8601::Duration) }
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
