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
                  (\2)?(\d{2})
                )?
              )?
              (?:
                T(\d{2})
                (?:
                  (:)?(\d{2})
                )?
                (?:
                  (\7)?(\d{2})
                )?
                (
                  Z|([+-])
                    (\d{2})
                    (?:
                      (\7)?
                      (\d{2})
                    )?
                )?
              )?
            $/x.match(dateTime) or raise ISO8601::Errors::UnknownPattern.new(dateTime)

      @dateTime = dateTime
      @time = @dt[6]
      @dateSeparator = @dt[2] == @dt[4] ? @dt[2] : nil
      @timeSeparator = 
      if (!@dt[7].nil? and (!@dt[9].nil? and !@dt[10].nil?) and (!@dt[14].nil? and !@dt[15].nil?)) or
         (!@dt[7].nil? and (!@dt[9].nil? and !@dt[10].nil?) and @dt[15].nil?) or
         (!@dt[7].nil? and @dt[10].nil? and @dt[15].nil?)
        @dt[7]
      else
        nil
      end
      @year = @dt[1].nil? ? nil : @dt[1].to_i
      @month = @dt[3].nil? ? nil : @dt[3].to_i
      @day = @dt[5].nil? ? nil : @dt[5].to_i
      @hour = @dt[6].nil? ? nil : @dt[6].to_i
      @minute = @dt[8].nil? ? nil : @dt[8].to_i
      @second = @dt[10].nil? ? nil : @dt[10].to_i
      @timezone = {
        :full => @dt[11],
        :sign => @dt[12],
        :hour => @dt[13].nil? ? nil : @dt[13].to_i,
        :minute => @dt[15].nil? ? nil : @dt[15].to_i,
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
