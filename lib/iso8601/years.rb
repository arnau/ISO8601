# encoding: utf-8

module ISO8601
  ##
  # A Years atom in a {ISO8601::Duration}
  #
  # A "calendar year" is the cyclic time interval in a calendar which is
  # required for one revolution of the Earth around the Sun and approximated to
  # an integral number of "calendar days".
  #
  # A "duration year" is the duration of 365 or 366 "calendar days" depending
  # on the start and/or the end of the corresponding time interval within the
  # specific "calendar year".
  class Years < ISO8601::Atom
    ##
    # The Year factor
    #
    # The "duration year" average is calculated through time intervals of 400
    # "duration years". Each cycle of 400 "duration years" has 303 "common
    # years" of 365 "calendar days" and 97 "leap years" of 366 "calendar days".
    #
    # @return [Integer]
    def factor
      return default_factor if base.nil?
      return adjusted_time if atom.zero?

      adjusted_time / atom
    end

    def adjusted_time
      ::Time.utc((base.year + atom).to_i) - ::Time.utc(base.year)
    end

    def default_factor
      ((365 * 303 + 366 * 97) / 400) * 86400
    end

    ##
    # The atom symbol.
    #
    # @return [Symbol]
    def symbol
      :Y
    end
  end
end
