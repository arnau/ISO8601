# encoding: utf-8

module ISO8601
  ##
  # A duration representation. When no base is provided, all atoms use an
  # average factor which affects the result of any computation like
  # `#to_seconds`.
  #
  # @example
  #     d = ISO8601::Duration.new('P2Y1MT2H')
  #     d.years  # => #<ISO8601::Years:0x000000051adee8 @atom=2.0, @base=nil>
  #     d.months # => #<ISO8601::Months:0x00000004f230b0 @atom=1.0, @base=nil>
  #     d.days   # => #<ISO8601::Days:0x00000005205468 @atom=0, @base=nil>
  #     d.hours  # => #<ISO8601::Hours:0x000000051e02a8 @atom=2.0, @base=nil>
  #     d.to_seconds # => 65707200.0
  #
  # @example Explicit base date time
  #     base = ISO8601::DateTime.new('2014-08017')
  #     d = ISO8601::Duration.new('P2Y1MT2H', base)
  #     d.years  # => #<ISO8601::Years:0x000000051adee8 @atom=2.0,
  #                     @base=#<ISO8601::DateTime...>>
  #     d.months # => #<ISO8601::Months:0x00000004f230b0 @atom=1.0,
  #                     @base=#<ISO8601::DateTime...>>
  #     d.days   # => #<ISO8601::Days:0x00000005205468 @atom=0,
  #                     @base=#<ISO8601::DateTime...>>
  #     d.hours  # => #<ISO8601::Hours:0x000000051e02a8 @atom=2.0,
  #                     @base=#<ISO8601::DateTime...>>
  #     d.to_seconds # => 65757600.0
  #
  # @example Number of seconds versus patterns
  #     di = ISO8601::Duration.new(65707200)
  #     dp = ISO8601::Duration.new('P2Y1MT2H')
  #     ds = ISO8601::Duration.new('P65707200S')
  #     di == dp # => true
  #     di == ds # => true
  #
  class Duration
    ##
    # @param [String, Numeric] input The duration pattern
    # @param [ISO8601::DateTime, nil] base (nil) The base datetime to
    #   calculate the duration against an specific point in time.
    def initialize(input, base = nil)
      @original = input
      @pattern = to_pattern
      @atoms = atomize(@pattern)
      @base = validate_base(base)
    end
    ##
    # Raw atoms result of parsing the given pattern.
    #
    # @return [Hash<Float>]
    attr_reader :atoms
    ##
    # Datetime base.
    #
    # @return [ISO8601::DateTime, nil]
    attr_reader :base
    ##
    # Assigns a new base datetime
    #
    # @return [ISO8601::DateTime, nil]
    def base=(value)
      @base = validate_base(value)
      @base
    end
    ##
    # @return [String] The string representation of the duration
    attr_reader :pattern
    alias_method :to_s, :pattern
    ##
    # @return [ISO8601::Years] The years of the duration
    def years
      ISO8601::Years.new(atoms[:years], base)
    end
    ##
    # @return [ISO8601::Months] The months of the duration
    def months
      # Changes the base to compute the months for the right base year
      month_base = base.nil? ? nil : base + years.to_seconds
      ISO8601::Months.new(atoms[:months], month_base)
    end
    ##
    # @return [ISO8601::Weeks] The weeks of the duration
    def weeks
      ISO8601::Weeks.new(atoms[:weeks], base)
    end
    ##
    # @return [ISO8601::Days] The days of the duration
    def days
      ISO8601::Days.new(atoms[:days], base)
    end
    ##
    # @return [ISO8601::Hours] The hours of the duration
    def hours
      ISO8601::Hours.new(atoms[:hours], base)
    end
    ##
    # @return [ISO8601::Minutes] The minutes of the duration
    def minutes
      ISO8601::Minutes.new(atoms[:minutes], base)
    end
    ##
    # @return [ISO8601::Seconds] The seconds of the duration
    def seconds
      ISO8601::Seconds.new(atoms[:seconds], base)
    end
    ##
    # The Integer representation of the duration sign.
    #
    # @return [Integer]
    attr_reader :sign
    ##
    # @return [ISO8601::Duration] The absolute representation of the duration
    def abs
      self.class.new(pattern.sub(/^[-+]/, ''), base)
    end
    ##
    # Addition
    #
    # @param [ISO8601::Duration] other The duration to add
    #
    # @raise [ISO8601::Errors::DurationBaseError] If bases doesn't match
    # @return [ISO8601::Duration]
    def +(other)
      compare_bases(other)
      seconds_to_iso(to_seconds + other.to_seconds)
    end
    ##
    # Substraction
    #
    # @param [ISO8601::Duration] other The duration to substract
    #
    # @raise [ISO8601::Errors::DurationBaseError] If bases doesn't match
    # @return [ISO8601::Duration]
    def -(other)
      compare_bases(other)
      seconds_to_iso(to_seconds - other.to_seconds)
    end
    ##
    # @param [ISO8601::Duration] other The duration to compare
    #
    # @raise [ISO8601::Errors::DurationBaseError] If bases doesn't match
    # @return [Boolean]
    def ==(other)
      compare_bases(other)
      (to_seconds == other.to_seconds)
    end
    ##
    # @param [ISO8601::Duration] other The duration to compare
    #
    # @return [Boolean]
    def eql?(other)
      (hash == other.hash)
    end
    ##
    # @return [Fixnum]
    def hash
      [atoms.values, self.class].hash
    end
    ##
    # Converts original input into  a valid ISO 8601 duration pattern.
    #
    # @return [String]
    def to_pattern
      (@original.is_a? Numeric) ? "PT#{@original}S" : @original
    end
    ##
    # @return [Numeric] The duration in seconds
    def to_seconds
      atoms = [years, months, weeks, days, hours, minutes, seconds]
      atoms.map(&:to_seconds).reduce(&:+)
    end
    ##
    # @return [Numeric] The duration in days
    def to_days
      (to_seconds / 86400)
    end
    ##
    # @return [Integer] The integer part of the duration in seconds
    def to_i
      to_seconds.to_i
    end
    ##
    # @return [Float] The duration in seconds coerced to float
    def to_f
      to_seconds.to_f
    end

    private

    ##
    # Splits a duration pattern into valid atoms.
    #
    # Acceptable patterns:
    #
    # * PnYnMnD
    # * PTnHnMnS
    # * PnYnMnDTnHnMnS
    # * PnW
    #
    # Where `n` is any number. If it contains a decimal fraction, a dot (`.`) or
    # comma (`,`) can be used.
    #
    # @param [String] input
    #
    # @return [Hash<Float>]
    def atomize(input)
      duration = input.match(/^
        (?<sign>\+|-)?
        P(?:
          (?:
            (?:(?<years>\d+(?:[,.]\d+)?)Y)?
            (?:(?<months>\d+(?:[.,]\d+)?)M)?
            (?:(?<days>\d+(?:[.,]\d+)?)D)?
            (?<time>T
              (?:(?<hours>\d+(?:[.,]\d+)?)H)?
              (?:(?<minutes>\d+(?:[.,]\d+)?)M)?
              (?:(?<seconds>\d+(?:[.,]\d+)?)S)?
            )?
          ) |
          (?<weeks>\d+(?:[.,]\d+)?W)
        ) # Duration
      $/x) || fail(ISO8601::Errors::UnknownPattern, input)

      valid_pattern?(duration)

      @sign = (duration[:sign] == '-') ? -1 : 1

      components = duration.names.zip(duration.captures).map! do |k, v|
        value = v.nil? ? v : v.tr(',', '.')
        [k.to_sym, sign * value.to_f]
      end
      components = Hash[components]
      components.delete(:time) # clean time capture

      valid_fractions?(components.values)

      components
    end
    ##
    # @param [Numeric] value The seconds to promote
    #
    # @return [ISO8601::Duration]
    def seconds_to_iso(value)
      return self.class.new('PT0S') if value.zero?

      sign_str = (value < 0) ? '-' : ''
      value = value.abs

      y, y_mod = decompose_atom(value, years)
      m, m_mod = decompose_atom(y_mod, months)
      d, d_mod = decompose_atom(m_mod, days)
      h, h_mod = decompose_atom(d_mod, hours)
      mi, mi_mod = decompose_atom(h_mod, minutes)
      s = Seconds.new(mi_mod)

      date = to_date_s(sign_str, y, m, d)
      time = to_time_s(h, mi, s)

      self.class.new(date + time)
    end

    def decompose_atom(value, atom)
      [atom.class.new((value / atom.factor).to_i), (value % atom.factor)]
    end

    def to_date_s(sign, *args)
      "#{sign}P#{args.map(&:to_s).join('')}"
    end

    def to_time_s(*args)
      (args.map(&:value).reduce(&:+) > 0) ? "T#{args.map(&:to_s).join('')}" : ''
    end

    def validate_base(input)
      fail ISO8601::Errors::TypeError unless input.nil? || input.is_a?(ISO8601::DateTime)

      input
    end

    def valid_pattern?(components)
      date = [
        components[:years], components[:months], components[:days]
      ]
      time = [
        components[:hours], components[:minutes], components[:seconds]
      ].compact
      weeks = components[:weeks]
      all = [date, time, weeks].flatten.compact

      missing_time = (weeks.nil? && !components[:time].nil? && time.empty?)
      empty = missing_time || all.empty?
      fail ISO8601::Errors::UnknownPattern, @pattern if empty
    end

    def valid_fractions?(values)
      values = values.reject(&:zero?)
      fractions = values.select { |a| (a % 1) != 0 }
      consistent = (fractions.size == 1 && fractions.last != values.last)

      fail ISO8601::Errors::InvalidFractions if fractions.size > 1 || consistent
    end

    def compare_bases(other)
      fail ISO8601::Errors::DurationBaseError, other if base != other.base
    end
  end
end
