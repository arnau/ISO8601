module ISO8601
  class Duration
    attr_reader :base
    def initialize(duration, base = nil)
      @duration = /^P(\d+Y)?(\d+M)?(\d+D)?(T(\d+H)?(\d+M)?(\d+S)?)?$/.match(duration)
      @base = base #date base for duration calculations
      valid_pattern?
    end
    def to_s
      @duration[0]
    end
    def years
      atom = @duration[1].nil? ? 0 : @duration[1].chop.to_i
      ISO8601::Years.new(atom, @base)
    end
    def months
      atom = @duration[2].nil? ? 0 : @duration[2].chop.to_i
      ISO8601::Months.new(atom, @base)
    end
    def days
      atom = @duration[3].nil? ? 0 : @duration[3].chop.to_i
      ISO8601::Days.new(atom, @base)
    end
    def hours
      atom = @duration[5].nil? ? 0 : @duration[5].chop.to_i
      ISO8601::Hours.new(atom, @base)
    end
    def minutes
      atom = @duration[6].nil? ? 0 : @duration[6].chop.to_i
      ISO8601::Minutes.new(atom, @base)
    end
    def seconds
      atom = @duration[7].nil? ? 0 : @duration[7].chop.to_i
      ISO8601::Seconds.new(atom, @base)
    end
    def to_seconds
      years, months, days, hours, minutes, seconds = self.years.to_seconds, self.months.to_seconds, self.days.to_seconds, self.hours.to_seconds, self.minutes.to_seconds, self.seconds.to_seconds
      return years + months + days + hours + minutes + seconds
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
      # return self.seconds_to_iso(d1 - d2)
      return d1 - d2
    end
    
    def seconds_to_iso(duration)
      years, y_mod = (duration / self.years.factor).to_i, (duration % self.years.factor)
      months, m_mod = (y_mod / self.months.factor).to_i, (y_mod % self.months.factor)
      days, d_mod = (m_mod / self.days.factor).to_i, (m_mod % self.days.factor)
      hours, h_mod = (m_mod / self.hours.factor).to_i, (d_mod % self.hours.factor)
      minutes, mi_mod = (h_mod / self.minutes.factor).to_i, (h_mod % self.minutes.factor)
      seconds = mi_mod.to_i
      
      years = (years != 0) ? "#{years}Y" : ""
      months = (months != 0) ? "#{months}M" : ""
      days = (days != 0) ? "#{days}D" : ""
      hours = (hours != 0) ? "#{hours}H" : ""
      minutes = (minutes != 0) ? "#{minutes}M" : ""
      seconds = (seconds != 0) ? "#{seconds}S" : ""

      return ISO8601::Duration.new(%[P#{years}#{months}#{days}T#{hours}#{minutes}#{seconds}])
    end
    
    private
      def valid_pattern?
        if @duration.nil? or 
           (@duration[1].nil? and @duration[2].nil? and @duration[3].nil? and @duration[4].nil?) or 
           (!@duration[4].nil? and @duration[5].nil? and @duration[6].nil? and @duration[7].nil?)
          raise ISO8601::Errors::UnknownPattern.new(@duration)
        end
      end
  end
end
