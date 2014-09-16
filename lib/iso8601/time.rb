module ISO8601
  ##
  # A Time representation
  #
  # @example
  #     t = Time.new('10:11:12')
  #     t = Time.new('T10:11:12.5Z')
  #     t.hour # => 10
  #     t.minute # => 11
  #     t.second # => 12.5
  #     t.zone # => '+00:00'
  class Time
    extend Forwardable

    def_delegators(
      :@time,
      :to_time, :to_date, :to_datetime,
      :hour, :minute, :zone
    )
    ##
    # The separator used in the original ISO 8601 string.
    attr_reader :separator
    ##
    # The second atom
    attr_reader :second
    ##
    # The original atoms
    attr_reader :atoms

    FORMAT = 'T%H:%M:%S%:z'
    FORMAT_WITH_FRACTION = 'T%H:%M:%S.%2N%:z'

    ##
    # @param [String] input The time pattern
    # @param [Date] base The base date to determine the time
    def initialize(input, base = ::Date.today)
      @original = input
      @base = base
      @atoms = atomize(input)
      @time = compose(@atoms, @base)
      @second = @time.second + @time.second_fraction.to_f
    end
    ##
    # @param [#hash] other The contrast to compare against
    #
    # @return [Boolean]
    def ==(other)
      (hash == other.hash)
    end
    ##
    # @param [#hash] other The contrast to compare against
    #
    # @return [Boolean]
    def eql?(other)
      (hash == other.hash)
    end
    ##
    # @return [Fixnum]
    def hash
      [atoms, self.class].hash
    end
    ##
    # Forwards the time the given amount of seconds.
    #
    # @param [Numeric] other The seconds to add
    #
    # @return [ISO8601::Time] New time resulting of the addition
    def +(other)
      moment = @time.to_time.localtime(zone) + other
      format = moment.subsec.zero? ? FORMAT : FORMAT_WITH_FRACTION
      base = ::Date.parse(moment.strftime('%Y-%m-%d'))

      ISO8601::Time.new(moment.strftime(format), base)
    end
    ##
    # Backwards the date the given amount of seconds.
    #
    # @param [Numeric] other The seconds to remove
    #
    # @return [ISO8601::Time] New time resulting of the substraction
    def -(other)
      moment = @time.to_time.localtime(zone) - other
      format = moment.subsec.zero? ? FORMAT : FORMAT_WITH_FRACTION
      base = ::Date.parse(moment.strftime('%Y-%m-%d'))

      ISO8601::Time.new(moment.strftime(format), base)
    end
    ##
    # Converts self to a time component representation.
    def to_s
      format = @time.second_fraction.zero? ? FORMAT : FORMAT_WITH_FRACTION
      @time.strftime(format)
    end
    ##
    # Converts self to an array of atoms.
    def to_a
      [hour, minute, second, zone]
    end

    private

    ##
    # Splits the time component into valid atoms.
    # Acceptable patterns: hh, hh:mm or hhmm and hh:mm:ss or hhmmss. Any form
    # can be prepended by `T`.
    #
    # @param [String] input
    #
    # @return [Array<Integer, Float>]
    def atomize(input)
      _, time, zone = /^T?(.+?)(Z|[+-].+)?$/.match(input).to_a

      _, hour, separator, minute, second = /^(?:
        (\d{2})(:?)(\d{2})\2(\d{2}(?:[.,]\d+)?) |
        (\d{2})(:?)(\d{2}) |
        (\d{2})
      )$/x.match(time).to_a.compact

      fail ISO8601::Errors::UnknownPattern, @original if hour.nil?

      @separator = separator

      hour = hour.to_i
      minute &&= minute.to_i
      second &&= second.tr(',', '.').to_f

      fail ISO8601::Errors::UnknownPattern, @original unless valid_zone?(zone)

      [hour, minute, second, zone].compact
    end

    def valid_zone?(zone)
      zone_regexp = /^(Z|[+-]\d{2}(?:(:?)\d{2})?)$/
      _, offset, separator = zone_regexp.match(zone).to_a.compact

      wrong_pattern = !zone.nil? && offset.nil?
      invalid_separators = zone.to_s.match(/^[+-]\d{2}:?\d{2}$/) && (@separator != separator)

      !(wrong_pattern || invalid_separators)
    end
    ##
    # Wraps ::DateNew.new to play nice with ArgumentError.
    #
    # @param [Array<Integer>] atoms The time atoms.
    # @param [::Date] base The base date to start computing time.
    #
    # @return [::DateTime]
    def compose(atoms, base)
      ::DateTime.new(*[base.year, base.month, base.day], *atoms)
    rescue ArgumentError
      raise ISO8601::Errors::RangeError, @original
    end
  end
end
