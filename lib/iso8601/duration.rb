module ISO8601
  class Duration
    def initialize(duration, base = nil)
      @duration = /^P(\d+Y)?(\d+M)?(\d+D)?(T(\d+H)?(\d+M)?(\d+S)?)?$/.match(duration)
      @base = base #date base for duration calculations
      valid_pattern?
    end
    def years
      atom = @duration[1].nil? ? 0 : @duration[1].chop.to_i
      ISO8601::Year.new(atom, @base)
    end
    def months
      atom = @duration[2].nil? ? 0 : @duration[2].chop.to_i
      ISO8601::Month.new(atom, @base)
    end
    def days
      atom = @duration[3].nil? ? 0 : @duration[3].chop.to_i
      ISO8601::Day.new(atom, @base)
    end
    def hours
      atom = @duration[5].nil? ? 0 : @duration[5].chop.to_i
      ISO8601::Hour.new(atom, @base)
    end
    def minutes
      atom = @duration[6].nil? ? 0 : @duration[6].chop.to_i
      ISO8601::Minute.new(atom, @base)
    end
    def seconds
      atom = @duration[7].nil? ? 0 : @duration[7].chop.to_i
      ISO8601::Second.new(atom, @base)
    end
    def to_seconds
      years = self.years.to_seconds
      months = self.months.to_seconds
      days = self.days.to_seconds
      hours = self.hours.to_seconds
      minutes = self.minutes.to_seconds
      seconds = self.seconds.to_seconds

      return years + months + days + hours + minutes + seconds
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
