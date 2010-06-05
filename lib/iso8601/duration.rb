module ISO8601
  
  # Represents a duration in ISO 8601 format
  class Duration
    attr_reader :base
    def initialize(duration, base = nil)
      @duration = /^(\+|-)?P(\d+Y)?(\d+M)?(\d+D)?(T(\d+H)?(\d+M)?(\d+S)?)?$/.match(duration)
      @base = base #date base for duration calculations
      valid_pattern?
    end

    # Returns the original string of the duration
    def to_s
      @duration[0]
    end

    # Returns the years of the duration
    def years
      atom = @duration[2].nil? ? 0 : @duration[2].chop.to_i
      ISO8601::Years.new(atom * sign, @base)
    end

    # Returns the months of the duration
    def months
      atom = @duration[3].nil? ? 0 : @duration[3].chop.to_i
      ISO8601::Months.new(atom * sign, @base)
    end

    # Returns the days of the duration
    def days
      atom = @duration[4].nil? ? 0 : @duration[4].chop.to_i
      ISO8601::Days.new(atom * sign, @base)
    end

    # Returns the hours of the duration
    def hours
      atom = @duration[6].nil? ? 0 : @duration[6].chop.to_i
      ISO8601::Hours.new(atom * sign, @base)
    end

    # Returns the minutes of the duration
    def minutes
      atom = @duration[7].nil? ? 0 : @duration[7].chop.to_i
      ISO8601::Minutes.new(atom * sign, @base)
    end
    
    # Returns the seconds of the duration
    def seconds
      atom = @duration[8].nil? ? 0 : @duration[8].chop.to_i
      ISO8601::Seconds.new(atom * sign, @base)
    end
    
    # Returns the duration in seconds
    def to_seconds
      years, months, days, hours, minutes, seconds = self.years.to_seconds, self.months.to_seconds, self.days.to_seconds, self.hours.to_seconds, self.minutes.to_seconds, self.seconds.to_seconds
      return years + months + days + hours + minutes + seconds
    end
    
    # Returns the absolute value of duration
    def abs
      return self.to_s.sub!(/^[-+]/, "")
    end
    
    def +(duration)
      raise ISO8601::Errors::DurationBaseError.new(duration) if self.base != duration.base
      d1 = self.to_seconds
      d2 = duration.to_seconds
      return self.seconds_to_iso(d1 + d2)
    end
    def -(duration)
      raise ISO8601::Errors::DurationBaseError.new(duration) if self.base != duration.base
      d1 = self.to_seconds
      d2 = duration.to_seconds
      return self.seconds_to_iso(d1 - d2)
      # return d1 - d2
    end
    
    def seconds_to_iso(duration)
      sign = "-" if (duration < 0)
      duration = duration.abs
      years, y_mod = (duration / self.years.factor).to_i, (duration % self.years.factor)
      months, m_mod = (y_mod / self.months.factor).to_i, (y_mod % self.months.factor)
      days, d_mod = (m_mod / self.days.factor).to_i, (m_mod % self.days.factor)
      hours, h_mod = (m_mod / self.hours.factor).to_i, (d_mod % self.hours.factor)
      minutes, mi_mod = (h_mod / self.minutes.factor).to_i, (h_mod % self.minutes.factor)
      seconds = mi_mod.to_i
      
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

      def valid_pattern?
        if @duration.nil? or 
           (@duration[2].nil? and @duration[3].nil? and @duration[4].nil? and @duration[5].nil?) or 
           (!@duration[5].nil? and @duration[6].nil? and @duration[7].nil? and @duration[8].nil?)
          raise ISO8601::Errors::UnknownPattern.new(@duration)
        end
      end
  end
end
