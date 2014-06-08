module ISO8601
  ##
  # A Date representation
  #
  # @example
  #     d = Date.new('2014-05-28')
  #     d.year  # => 2014
  #     d.month # => 5
  #
  # @example Week dates
  #     d = Date.new('2014-W15-2')
  #     d.day   # => 27
  #     d.wday  # => 2
  #     d.week # => 15
  class Date
    extend Forwardable

    def_delegators(:@date,
      :to_s, :to_time, :to_date, :to_datetime,
      :year, :month, :day, :wday)
    ##
    # The original atoms
    attr_reader :atoms
    ##
    # The separator used in the original ISO 8601 string.
    attr_reader :separator
    ##
    # @param [String] input The date pattern
    def initialize(input)
      @original = input

      @atoms = atomize(input)
      @date = ::Date.new(*@atoms)
    rescue ArgumentError
      raise ISO8601::Errors::RangeError, input
    end
    ##
    # The calendar week number (1-53)
    def week
      @date.cweek
    end
    ##
    # Forwards the date the given amount of days.
    #
    # @param [Numeric] days The days to add
    #
    # @return [ISO8601::Date] New date resulting of the addition
    def +(days)
      ISO8601::Date.new((@date + days).iso8601)
    end
    ##
    # Backwards the date the given amount of days.
    #
    # @param [Numeric] days The days to remove
    #
    # @return [ISO8601::Date] New date resulting of the substraction
    def -(days)
      ISO8601::Date.new((@date - days).iso8601)
    end
    ##
    # Converts self to an array of atoms.
    def to_a
      [year, month, day]
    end

    private
    ##
    # Splits the date component into valid atoms.
    #
    # Acceptable patterns:
    #
    # * YYYY
    # * YYYY-MM but not YYYYMM
    # * YYYY-MM-DD, YYYYMMDD
    # * YYYY-Www, YYYYWdd
    # * YYYY-Www-D, YYYYWddD
    # * YYYY-DDD, YYYYDDD
    #
    # @param [String] input
    #
    # @return [Array<Integer>]
    def atomize(input)
      week_date = /^([+-]?)\d{4}(-?)W\d{2}(?:\2\d)?$/.match(input)
      return atomize_week_date(input, week_date[2], week_date[1]) unless week_date.nil?

      _, sign, year, separator, day = /^([+-]?)(\d{4})(-?)(\d{3})$/.match(input).to_a.compact
      return atomize_ordinal(year, day, separator, sign) unless year.nil?

      _, year, separator, month, day = /^
        ([+-]?\d{4})   # YYYY
        (?:
          (-?)(\d{2})  # YYYY-MM
          (?:
            \2(\d{2})  # YYYY-MM-DD
          )?
        )?
      $/x.match(input).to_a.compact

      raise ISO8601::Errors::UnknownPattern.new(@original) if year.nil?

      @separator = separator

      [year, month, day].compact.map(&:to_i)
    end
    ##
    # Parses a week date (YYYY-Www-D, YYYY-Www) and returns its atoms.
    #
    # @param [String] input the date string.
    # @param [String] separator the separator found in the input.
    # @param [String] sign the sign found in the input.
    #
    # @return [Array<Integer>] date atoms.
    def atomize_week_date(input, separator, sign)
      date = ::Date.parse(input)
      sign = "#{sign}1".to_i
      @separator = separator

      [sign * date.year, date.month, date.day]
    end
    ##
    # Parses an ordinal date (YYYY-DDD) and returns its atoms.
    #
    # @param [String] year in YYYY form.
    # @param [String] day in DDD form.
    # @param [String] separator the separator found in the input.
    # @param [String] sign the sign found in the input.
    #
    # @return [Array<Integer>] date atoms.
    def atomize_ordinal(year, day, separator, sign)
      date = ::Date.parse([year, day].join('-'))
      sign = "#{sign}1".to_i
      @separator = separator

      [sign * date.year, date.month, date.day]
    end
  end
end
