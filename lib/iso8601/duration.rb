# encoding: utf-8

module ISO8601
  ##
  # A duration representation. When no base is provided, all atoms use an
  # average factor which affects the result of any computation like `#to_seconds`.
  #
  # @example
  #     d = ISO8601::Duration.new('P2Y1MT2H')
  #     d.years  # => #<ISO8601::Years:0x000000051adee8 @atom=2.0, @base=nil>
  #     d.months # => #<ISO8601::Months:0x00000004f230b0 @atom=1.0, @base=nil>
  #     d.days   # => #<ISO8601::Days:0x00000005205468 @atom=0, @base=nil>
  #     d.hours  # => #<ISO8601::Hours:0x000000051e02a8 @atom=2.0, @base=nil>
  #     d.to_seconds # => 65707200.0
  #
  # @example Explicit base date time
  #     d = ISO8601::Duration.new('P2Y1MT2H', ISO8601::DateTime.new('2014-08017'))
  #     d.years  # => #<ISO8601::Years:0x000000051adee8 @atom=2.0, @base=#<ISO8601::DateTime...>>
  #     d.months # => #<ISO8601::Months:0x00000004f230b0 @atom=1.0, @base=#<ISO8601::DateTime...>>
  #     d.days   # => #<ISO8601::Days:0x00000005205468 @atom=0, @base=#<ISO8601::DateTime...>>
  #     d.hours  # => #<ISO8601::Hours:0x000000051e02a8 @atom=2.0, @base=#<ISO8601::DateTime...>>
  #     d.to_seconds # => 65757600.0
  #
  # @example Number of seconds versus patterns
  #     di = ISO8601::Duration.new(65707200)
  #     dp = ISO8601::Duration.new('P2Y1MT2H')
  #     ds = ISO8601::Duration.new('P65707200S')
  #     di == dp # => true
  #     di == ds # => true
  #
  class Duration
    ##
    # @param [String, Numeric] input The duration pattern
    # @param [ISO8601::DateTime, nil] base (nil) The base datetime to
    #   calculate the duration against an specific point in time.
    def initialize(input, base = nil)
      @original = input
      # we got seconds instead of an ISO8601 duration
      @pattern = (input.kind_of? Numeric) ? "PT#{input}S" : input
      @duration = /^(\+|-)? # Sign
                   P(
                      (
                        (\d+(?:[,.]\d+)?Y)? # Years
                        (\d+(?:[.,]\d+)?M)? # Months
                        (\d+(?:[.,]\d+)?D)? # Days
                        (T
                          (\d+(?:[.,]\d+)?H)? # Hours
                          (\d+(?:[.,]\d+)?M)? # Minutes
                          (\d+(?:[.,]\d+)?S)? # Seconds
                        )? # Time
                      )
                      |(\d+(?:[.,]\d+)?W) # Weeks
                    ) # Duration
                  $/x.match(@pattern) or raise ISO8601::Errors::UnknownPattern.new(@pattern)

      @base = base
      valid_pattern?
      valid_base?
      @atoms = {
        :years => @duration[4].nil? ? 0 : @duration[4].chop.to_f * sign,
        :months => @duration[5].nil? ? 0 : @duration[5].chop.to_f * sign,
        :weeks => @duration[11].nil? ? 0 : @duration[11].chop.to_f * sign,
        :days => @duration[6].nil? ? 0 : @duration[6].chop.to_f * sign,
        :hours => @duration[8].nil? ? 0 : @duration[8].chop.to_f * sign,
        :minutes => @duration[9].nil? ? 0 : @duration[9].chop.to_f * sign,
        :seconds => @duration[10].nil? ? 0 : @duration[10].chop.to_f * sign
      }
      valid_fractions?
    end
    ##
    # Raw atoms result of parsing the given pattern.
    #
    # @return [Hash<Float>]
    attr_reader :atoms
    ##
    # Datetime base.
    #
    # @return [ISO8601::DateTime, nil]
    attr_reader :base
    ##
    # Assigns a new base datetime
    #
    # @return [ISO8601::DateTime, nil]
    def base=(value)
      @base = value
      valid_base?
      return @base
    end
    ##
    # @return [String] The string representation of the duration
    attr_reader :pattern
    ##
    # @return [String] The string representation of the duration
    def to_s
      pattern.to_s
    end
    ##
    # @return [ISO8601::Years] The years of the duration
    def years
      ISO8601::Years.new(@atoms[:years], @base)
    end
    ##
    # @return [ISO8601::Months] The months of the duration
    def months
      # Changes the base to compute the months for the right base year
      base = @base.nil? ? nil : @base + self.years.to_seconds
      ISO8601::Months.new(@atoms[:months], base)
    end
    ##
    # @return [ISO8601::Weeks] The weeks of the duration
    def weeks
      ISO8601::Weeks.new(@atoms[:weeks], @base)
    end
    ##
    # @return [ISO8601::Days] The days of the duration
    def days
      ISO8601::Days.new(@atoms[:days], @base)
    end
    ##
    # @return [ISO8601::Hours] The hours of the duration
    def hours
      ISO8601::Hours.new(@atoms[:hours], @base)
    end
    ##
    # @return [ISO8601::Minutes] The minutes of the duration
    def minutes
      ISO8601::Minutes.new(@atoms[:minutes], @base)
    end
    ##
    # @return [ISO8601::Seconds] The seconds of the duration
    def seconds
      ISO8601::Seconds.new(@atoms[:seconds], @base)
    end
    ##
    # @return [Numeric] The duration in seconds
    def to_seconds
      years, months, weeks, days, hours, minutes, seconds = self.years.to_seconds, self.months.to_seconds, self.weeks.to_seconds, self.days.to_seconds, self.hours.to_seconds, self.minutes.to_seconds, self.seconds.to_seconds
      return years + months + weeks + days + hours + minutes + seconds
    end
    ##
    # @return [ISO8601::Duration] The absolute representation of the duration
    def abs
      absolute = self.to_s.sub(/^[-+]/, '')
      return ISO8601::Duration.new(absolute)
    end
    ##
    # Addition
    #
    # @param [ISO8601::Duration] duration The duration to add
    #
    # @raise [ISO8601::Errors::DurationBaseError] If bases doesn't match
    # @return [ISO8601::Duration]
    def +(duration)
      raise ISO8601::Errors::DurationBaseError.new(duration) if @base.to_s != duration.base.to_s
      d1 = to_seconds
      d2 = duration.to_seconds
      return seconds_to_iso(d1 + d2)
    end
    ##
    # Substraction
    #
    # @param [ISO8601::Duration] duration The duration to substract
    #
    # @raise [ISO8601::Errors::DurationBaseError] If bases doesn't match
    # @return [ISO8601::Duration]
    def -(duration)
      raise ISO8601::Errors::DurationBaseError.new(duration) if @base.to_s != duration.base.to_s
      d1 = to_seconds
      d2 = duration.to_seconds
      duration = d1 - d2
      if duration == 0
        return ISO8601::Duration.new('PT0S')
      else
        return seconds_to_iso(duration)
      end
    end
    ##
    # @param [ISO8601::Duration] duration The duration to compare
    #
    # @raise [ISO8601::Errors::DurationBaseError] If bases doesn't match
    # @return [Boolean]
    def ==(duration)
      raise ISO8601::Errors::DurationBaseError.new(duration) if @base.to_s != duration.base.to_s
      (self.to_seconds == duration.to_seconds)
    end
    ##
    # @return [Fixnum]
    def hash
      @atoms.hash
    end


    private
    ##
    # @param [Numeric] duration The seconds to promote
    #
    # @return [ISO8601::Duration]
    def seconds_to_iso(duration)
      sign = '-' if (duration < 0)
      duration = duration.abs
      years, y_mod = (duration / self.years.factor).to_i, (duration % self.years.factor)
      months, m_mod = (y_mod / self.months.factor).to_i, (y_mod % self.months.factor)
      days, d_mod = (m_mod / self.days.factor).to_i, (m_mod % self.days.factor)
      hours, h_mod = (d_mod / self.hours.factor).to_i, (d_mod % self.hours.factor)
      minutes, mi_mod = (h_mod / self.minutes.factor).to_i, (h_mod % self.minutes.factor)
      seconds = mi_mod.div(1) == mi_mod ? mi_mod.to_i : mi_mod.to_f # Coerce to Integer when needed (`PT1S` instead of `PT1.0S`)

      seconds = (seconds != 0 or (years == 0 and months == 0 and days == 0 and hours == 0 and minutes == 0)) ? "#{seconds}S" : ""
      minutes = (minutes != 0) ? "#{minutes}M" : ""
      hours = (hours != 0) ? "#{hours}H" : ""
      days = (days != 0) ? "#{days}D" : ""
      months = (months != 0) ? "#{months}M" : ""
      years = (years != 0) ? "#{years}Y" : ""

      date = %[#{sign}P#{years}#{months}#{days}]
      time = (hours != "" or minutes != "" or seconds != "") ? %[T#{hours}#{minutes}#{seconds}] : ""
      date_time = date + time
      return ISO8601::Duration.new(date_time)
    end

    def sign
      (@duration[1].nil? or @duration[1] == "+") ? 1 : -1
    end
    def valid_base?
      if !(@base.nil? or @base.kind_of? ISO8601::DateTime)
        raise TypeError
      end
    end
    def valid_pattern?
      if @duration.nil? or
         (@duration[4].nil? and @duration[5].nil? and @duration[6].nil? and @duration[7].nil? and @duration[11].nil?) or
         (!@duration[7].nil? and @duration[8].nil? and @duration[9].nil? and @duration[10].nil? and @duration[11].nil?)

        raise ISO8601::Errors::UnknownPattern.new(@duration)
      end
    end

    def valid_fractions?
      values = @atoms.values.reject(&:zero?)
      fractions = values.select { |a| (a % 1) != 0 }
      if fractions.size > 1 || (fractions.size == 1 && fractions.last != values.last)
        raise ISO8601::Errors::InvalidFractions.new(@duration)
      end
    end
  end
end
