# encoding: utf-8

module ISO8601
  ##
  # A DateTime representation
  #
  # @todo Review the pattern `201005`. It has to be `20-10-05` instead of `2010-05`.
  #   The specification doesn't allow a YYYYMM. It should be always
  #   YYYY-MM.
  # @todo Change #+ and #- to return a ISO8601::DateTime instance
  class DateTime
    attr_reader :century, :year, :month, :day, :hour, :minute, :second, :timezone
    ##
    # @param [String] date_time The datetime pattern
    def initialize(date_time)
      @dt = /^(?:
                (\d{2})(\d{2})? # Year. It can be either two digits (the century) or four digits (the full year)
                (?:
                  (-)?(\d{2})
                )? # Month with an optional separator
                (?:
                  (\3)?(\d{2}) # Day with an optional separator which is the same for the Month
                )?
              )? # Date
              (?:
                T(\d{2}) # Hour
                (?:
                  (:)?(\d{2}) # Minute with an optional separator
                )?
                (?:
                  (\8)?(\d{2}) # Second with an optional separator which is the same that for the Minute
                )? # Time
                (
                  Z|([+-])
                    (\d{2}) # Timezone hour
                    (?:
                      (\8)? # Separator which should be the same that for the Minute
                      (\d{2}) # Timezone minute
                    )?
                )? # Timezone
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
      @century = @dt[1].to_i
      @year = @dt[2].nil? ? nil : (@dt[1] + @dt[2]).to_i
      @month = @dt[4].nil? ? nil : @dt[4].to_i
      @day = @dt[6].nil? ? nil : @dt[6].to_i
      @hour = @dt[7].nil? ? nil : @dt[7].to_i
      @minute = @dt[9].nil? ? nil : @dt[9].to_i
      @second = @dt[11].nil? ? nil : @dt[11].to_i
      @timezone = {
        :full => @dt[12].nil? ? (Time.now.gmt_offset / 3600) : (@dt[12] == "Z" ? 0 : @dt[12]),
        :sign => @dt[13],
        :hour => @dt[12].nil? ? (Time.now.gmt_offset / 3600) : (@dt[12] == "Z" ? 0 : @dt[14].to_i),
        :minute => (@dt[12].nil? or @dt[12] == "Z") ? 0 : @dt[13].to_i
      }

      valid_pattern?
      valid_range?
    end
    ##
    # Returns the datetime string representation
    def to_s
      @date_time
    end
    ##
    # Converts the object to a Time instance
    #
    # @return [Time] The object converted
    def to_time
      raise RangeError if @year.nil?
      if @month.nil?
        Time.utc(@year)
      elsif @day.nil?
        date = [@year, @month, '01'].join('-')
        Time.parse(date).getutc
      else
        Time.parse(@date_time).getutc
      end
    end
    ##
    # Addition
    #
    # @param [ISO8601::DateTime] The seconds to add
    def +(d)
      raise TypeError unless d.kind_of? Numeric
      ISO8601::DateTime.new((Time.utc(@year, @month, @day, @hour, @minute, @second) + d).to_datetime.iso8601)
    end
    ##
    # Substraction
    #
    # @param [ISO8601::DateTime] The seconds to substract
    def -(d)
      raise TypeError unless d.kind_of? Numeric
      ISO8601::DateTime.new((Time.utc(@year, @month, @day, @hour, @minute, @second) - d).to_datetime.iso8601)
    end
    private
      def valid_pattern?
        if (@date_separator.nil? and !@time_separator.nil?) or
           (!@date_separator.nil? and !@time.nil? and @time_separator.nil? and !@minute.nil?) or
           (@year.nil? and !@month.nil?)
          raise ISO8601::Errors::UnknownPattern.new(@date_time)
        elsif (@year.nil? and @month.nil?)
          @year = (@century.to_s + "00").to_i
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
