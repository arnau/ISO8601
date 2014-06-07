module ISO8601
  ##
  # A Date representation
  #
  # @example
  #     d = Date.new('2014-05-28')
  #     d.year  # => 2014
  #     d.month # => 5
  class Date
    extend Forwardable

    def_delegators(:@date,
      :to_s, :to_time, :to_date, :to_datetime,
      :year, :month, :day)
    ##
    # The original atoms
    attr_reader :atoms
    ##
    # The separator used in the original ISO 8601 string.
    attr_reader :separator
    ##
    # @param [String] date The date pattern
    def initialize(input)
      @original = input

      @atoms = atomize(input)
      @date = ::Date.new(*@atoms)
    rescue ArgumentError => error
      raise ISO8601::Errors::RangeError, input
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
    # Acceptable patterns: YYYY, YYYY-MM-DD, YYYYMMDD or YYYY-MM but not YYYYMM.
    #
    # @param [String] date
    #
    # @return [Array<Integer>]
    def atomize(date)
      _, year, separator, month, day = /^(?:
        ([+-]?\d{4})(-?)(\d{2})\2(\d{2}) | # YYYY-MM-DD
        ([+-]?\d{4})(-?)(\d{3}) | # YYYY-DDD
        ([+-]?\d{4})(-)(\d{2}) | # YYYY-MM
        ([+-]?\d{4}) # YYYY
      )$/x.match(date).to_a.compact

      raise ISO8601::Errors::UnknownPattern.new(@original) if year.nil?

      @separator = separator

      return atomize_ordinal(year, month) if month && month.length == 3

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
