# encoding: utf-8

module ISO8601
  ##
  # A DateTime representation
  #
  # @example
  #     dt = DateTime.new('2014-05-28T19:53Z')
  #     dt.year #=> 2014
  class DateTime
    extend Forwardable

    def_delegators(:@date_time,
      :to_s, :to_time, :to_date, :to_datetime,
      :year, :month, :day, :hour, :minute, :zone)

    attr_reader :second

    ##
    # @param [String] date_time The datetime pattern
    def initialize(date_time)
      @original = date_time
      @date_time = parse(date_time)
      @second = @date_time.second + @date_time.second_fraction.to_f
    end
    ##
    # Addition
    #
    # @param [ISO8601::DateTime] seconds The seconds to add
    def +(seconds)
      ISO8601::DateTime.new((@date_time.to_time + seconds).iso8601)
    end
    ##
    # Substraction
    #
    # @param [ISO8601::DateTime] seconds The seconds to substract
    def -(seconds)
      ISO8601::DateTime.new((@date_time.to_time - seconds).iso8601)
    end
    ##
    # Converts DateTime to an array of atoms.
    def to_a
      [year, month, day, hour, minute, second, zone]
    end

    private
    ##
    # Parses an ISO date time, where the date and the time components are
    # optional.
    #
    # It enhances the parsing capabilities of the native DateTime.
    #
    # @param [String] date_time The ISO representation
    def parse(date_time)
      date, time_zone = date_time.split('T')
      _, time, zone = /^(.+?)(Z|[+-].+)?$/.match(time_zone).to_a

      date_components = parse_date(date)
      time_components = Array(time && parse_time(time))
      zone_components = parse_zone(zone)
      separators = [
        date_components.pop,
        time_components.pop,
        zone_components.pop
      ]

      valid_representation?(date_components, time_components)
      valid_separators?(separators)

      components = date_components + time_components
      components = (components << zone).compact

      ::DateTime.new(*components)
    end
    ##
    # Validates the date has the right pattern.
    #
    # Acceptable patterns: YYYY, YYYY-MM-DD, YYYYMMDD or YYYY-MM but not YYYYMM
    #
    # @param [String] date
    #
    # @return [Array<String, nil>]
    def parse_date(date)
      today = Date.today
      return [today.year, today.month, today.day, :ignore] if date.empty?

      _, year, separator, month, day = /^(?:
        ([+-]?\d{4})(-?)(\d{2})\2(\d{2}) |
        ([+-]?\d{4})(-)(\d{2}) |
        ([+-]?\d{4})
      )$/x.match(date).to_a.compact

      raise ISO8601::Errors::UnknownPattern.new(@original) if year.nil?

      year = year.to_i
      month &&= month.to_i
      day &&= day.to_i

      [year, month, day, separator]
    end
    def parse_zone(zone)
      _, offset, separator = /^(Z|[+-]\d{2}(.)\d{2})$/.match(zone).to_a.compact

      [offset, separator]
    end
    ##
    # Validates the time has the right pattern.
    #
    # Acceptable patterns:
    #
    # * hh
    # * hh:mm or hhmm
    # * hh:mm:ss or hhmmss
    #
    # @return [Array<String, nil>]
    def parse_time(time)
      _, hours, separator, minutes, seconds = /^(?:
        (\d{2})(:?)(\d{2})\2(\d{2}(?:[.,]\d+)?) |
        (\d{2})(:)(\d{2}) |
        (\d{2})
      )$/x.match(time).to_a.compact

      raise ISO8601::Errors::UnknownPattern.new(@original) if hours.nil?

      hours &&= hours.to_i
      minutes &&= minutes.to_i
      seconds &&= seconds.to_f

      [hours, minutes, seconds, separator]
    end

    def valid_separators?(separators)
      separators = separators.compact

      return if separators.length == 1 || separators[0] == :ignore

      unless separators.all?(&:empty?)
        if (separators[0].length != separators[1].length)
          raise ISO8601::Errors::UnknownPattern, @original
        else
          if separators.length == 3 && !(separators[1] == separators[2])
            raise ISO8601::Errors::UnknownPattern, @original
          end
        end
      end
    end
    ##
    # If time is provided date must use a complete representation
    def valid_representation?(date, time)
      year, month, day = date
      hour, minute, second = time

      if !year.nil? && (month.nil? || day.nil?) && !hour.nil?
        raise ISO8601::Errors::UnknownPattern, @original
      end
    end
  end
end
