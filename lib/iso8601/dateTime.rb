module ISO8601
  class DateTime
    attr_reader :date_time, :century, :year, :month, :day, :hour, :minute, :second, :timezone
    def initialize(date_time)
      @dt = /^(?:
                (\d{2})(\d{2})?
                (?:
                  (-)?(\d{2})
                )?
                (?:
                  (\3)?(\d{2})
                )?
              )?
              (?:
                T(\d{2})
                (?:
                  (:)?(\d{2})
                )?
                (?:
                  (\8)?(\d{2})
                )?
                (
                  Z|([+-])
                    (\d{2})
                    (?:
                      (\8)?
                      (\d{2})
                    )?
                )?
              )?
            $/x.match(date_time) or raise ISO8601::Errors::UnknownPattern.new(date_time)

      @date_time = date_time
      @time = @dt[7]
      @date_separator = @dt[3] == @dt[5] ? @dt[3] : nil
      @time_separator = 
      if (!@dt[8].nil? and (!@dt[10].nil? and !@dt[11].nil?) and (!@dt[15].nil? and !@dt[16].nil?)) or
         (!@dt[8].nil? and (!@dt[10].nil? and !@dt[11].nil?) and @dt[16].nil?) or
         (!@dt[8].nil? and @dt[11].nil? and @dt[16].nil?)
        @dt[8]
      else
        nil
      end
      @century = @dt[1].nil? ? nil : @dt[1].to_i
      @year = @dt[2].nil? ? nil : (@dt[1] + @dt[2]).to_i
      @month = @dt[4].nil? ? nil : @dt[4].to_i
      @day = @dt[6].nil? ? nil : @dt[6].to_i
      @hour = @dt[7].nil? ? nil : @dt[7].to_i
      @minute = @dt[9].nil? ? nil : @dt[9].to_i
      @second = @dt[11].nil? ? nil : @dt[11].to_i
      @timezone = {
        :full => @dt[12],
        :sign => @dt[13],
        :hour => @dt[14].nil? ? nil : @dt[14].to_i,
        :minute => @dt[16].nil? ? nil : @dt[16].to_i,
      }

      valid_pattern?
      valid_range?
    end
    def to_time
      raise RangeError if @year.nil?
      if @month.nil?
        Time.utc(@year)
      else
        Time.parse(@date_time).getutc
      end
    end
    def +(d)
      raise TypeError unless (d.is_a? Float or d.is_a? Integer)
      Time.utc(@year, @month, @day, @hour, @minute, @second) + d
    end
    def -(d)
      raise TypeError unless (d.is_a? Float or d.is_a? Integer or d.is_a? ISO8601::DateTime)
      if (d.is_a? ISO8601::DateTime)
        Time.utc(@year, @month, @day, @hour, @minute, @second) - Time.utc(d.year, d.month, d.day, d.hour, d.minute, d.second)
      else
        Time.utc(@year, @month, @day, @hour, @minute, @second) - d
      end
    end
    private
      def valid_pattern?
        if (@date_separator.nil? and !@time_separator.nil?) or
           (!@date_separator.nil? and !@time.nil? and @time_separator.nil? and !@minute.nil?) or
           (@year.nil? and !@month.nil?)
          raise ISO8601::Errors::UnknownPattern.new(@date_time)
        end
      end
      def valid_range?
        if !month.nil? and (month < 1 or month > 12)
          raise RangeError
        elsif !day.nil? and (Time.parse(@date_time).month != month)
          raise RangeError
        end
      rescue ArgumentError => e
        raise RangeError
      end
  end
end
