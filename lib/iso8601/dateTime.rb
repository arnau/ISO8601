module ISO8601
  class DateTime
    attr_reader :dateTime, :year, :month, :day, :hour, :minute, :second, :timezone
    def initialize(dateTime)
      @dt = /^(?:
                (\d{4})
                (?:
                  (-)?(\d{2})
                )?
                (?:
                  \2?(\d{2})
                )?
              )?
              (?:
                T(\d{2})
                (?:
                  (:)?(\d{2})
                )?
                (?:
                  \6?(\d{2})
                )?
                (?:
                  (Z|([+-])(\d{2})(\6?\d{2})?)
                )?
              )?
            $/x.match(dateTime) or raise ISO8601::Errors::UnknownPattern.new(dateTime)

      @dateTime = dateTime

      @dateSeparator = @dt[2]
      @time = @dt[5]
      @timeSeparator = @dt[6]

      @year = @dt[1].nil? ? nil : @dt[1].to_i
      @month = @dt[3].nil? ? nil : @dt[3].to_i
      @day = @dt[4].nil? ? nil : @dt[4].to_i
      @hour = @dt[5].nil? ? nil : @dt[5].to_i
      @minute = @dt[7].nil? ? nil : @dt[7].to_i
      @second = @dt[8].nil? ? nil : @dt[8].to_i
      @timezone = {
        :full => @dt[9],
        :sign => @dt[10],
        :hour => @dt[11].nil? ? nil : @dt[11].to_i,
        :minute => @dt[12].nil? ? nil : @dt[12].to_i,
      }

      valid_pattern?
      valid_range?
    end
    def to_time
      Time.parse(@dateTime)
    end
    private
      def valid_pattern?
        if (@dateSeparator.nil? and !@timeSeparator.nil?) or
           (!@dateSeparator.nil? and !@time.nil? and @timeSeparator.nil? and !@minute.nil?)
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
