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
      _, year, separator, month, day = /^(?:
        ([+-]?\d{4})(-?)(\d{2})\2(\d{2}) | # YYYY-MM-DD
        ([+-]?\d{4})(-?)(\d{3}) |          # YYYY-DDD
        ([+-]?\d{4})(-)(\d{2}) |           # YYYY-MM
        ([+-]?\d{4})                       # YYYY
      )$/x.match(input).to_a.compact

      if year.nil?
        # Check if it's a Week date
        _, year, separator, week, wday = /^(?:
          ([+-]?\d{4})(-?)(W\d{2})\2(\d) | # YYYY-Www-D
          ([+-]?\d{4})(-?)(W\d{2})         # YYYY-Www
        )$/x.match(input).to_a.compact

        unless week.nil?
          d = ::Date.parse(input)
          year = d.year
          month = d.month
          day = d.day
        end
      end

      raise ISO8601::Errors::UnknownPattern.new(@original) if year.nil?

      @separator = separator

      return atomize_ordinal(year, month) if month && month.to_s.length == 3

      [year, month, day].compact.map(&:to_i)
    end
    ##
    # Parses an ordinal date (YYYY-DDD) and returns its atoms.
    #
    # @param [String] year in YYYY form.
    # @param [String] day in DDD form.
    #
    # @return [Array<Integer>] date atoms
    def atomize_ordinal(year, day)
      date = ::Date.parse([year, day].join('-'))

      [date.year, date.month, date.day]
    end
  end
end
