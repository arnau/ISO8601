# encoding: utf-8

module ISO8601
  ##
  # Represents a duration in ISO 8601 format
  #
  # @todo Support fraction values for years, months, days, weeks, hours
  #   and minutes
  class Duration
    attr_reader :base, :atoms
    ##
    # @param [String] duration The duration pattern
    # @param [ISO8601::DateTime, nil] base (nil) The base datetime to
    #   calculate the duration properly
    def initialize(duration, base = nil)
      @duration = /^(\+|-)? # Sign
                   P(
                      (
                        (\d+Y)? # Years
                        (\d+M)? # Months
                        (\d+D)? # Days
                        (T
                          (\d+H)? # Hours
                          (\d+M)? # Minutes
                          (\d+(?:\.\d+)?S)? # Seconds
                        )? # Time
                      )
                      |(\d+W) # Weeks
                    ) # Duration
                  $/x.match(duration) or raise ISO8601::Errors::UnknownPattern.new(duration)

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
    end
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
    def to_s
      @duration[0]
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

    # Returns the absolute value of duration
    def abs
      return self.to_s.sub!(/^[-+]/, "")
    end
    ##
    # Addition
    #
    # @param [ISO8601::Duration] duration The duration to add
    def +(duration)
      raise ISO8601::Errors::DurationBaseError.new(duration) if @base != duration.base
      d1 = self.to_seconds
      d2 = duration.to_seconds
      return seconds_to_iso(d1 + d2)
    end
    ##
    # Substraction
    #
    # @param [ISO8601::Duration] duration The duration to substract
    def -(duration)
      raise ISO8601::Errors::DurationBaseError.new(duration) if @base != duration.base
      d1 = to_seconds
      d2 = duration.to_seconds
      duration = d1 - d2
      if duration == 0
        return ISO8601::Duration.new('PT0S')
      else
        return seconds_to_iso(duration)
      end
    end

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

    private
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
  end
end
