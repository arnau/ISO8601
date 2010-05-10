module ISO8601
  class DateTime
    attr_reader :dateTime, :year, :month, :day
    def initialize(dateTime)
      @dt = /^(
                (\d{4})(-\d{2})?(-\d{2})?
              )?
              (
                T(\d{2})(:\d{2})?(:\d{2})?
              )?
            $/x.match(dateTime)
            2007-11-03T13:18:05
      @dateTime = dateTime
      valid_pattern?
      @year = @dt[2].nil? ? nil : @dt[2].to_i
      @month = if @dt[3].nil?
        nil
      else
        @dt[3].slice(1..-1).to_i
      end
      @day = @dt[4].nil? ? nil : @dt[4].slice(1..-1).to_i

      valid_range?
    end
    def to_time
      Time.parse(@dateTime)
    end
    private
      def valid_pattern?
        if @dt.nil?
          raise ISO8601::Errors::UnknownPattern.new(@dateTime)
        end
      end
      def valid_range?
        if !month.nil? and (month < 1 or month > 12)
          raise RangeError
        elsif !day.nil? and (Time.parse(@dateTime).month != month)
          raise RangeError
        end
      rescue ArgumentError => e
        raise RangeError
      end
  end
end
