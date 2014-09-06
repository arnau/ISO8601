# encoding: utf-8

module ISO8601
  ##
  # A generic atom in a {ISO8601::Duration}
  #
  # @abstract
  class Atom
    ##
    # @param [Numeric] atom The atom value
    # @param [ISO8601::DateTime, nil] base (nil) The base datetime to compute
    #   the atom factor.
    def initialize(atom, base=nil)
      raise TypeError, "The atom argument for #{self.inspect} should be a Numeric value." unless atom.kind_of?(Numeric)
      raise TypeError, "The base argument for #{self.inspect} should be a ISO8601::DateTime instance or nil." unless base.kind_of?(ISO8601::DateTime) || base.nil?
      @atom = atom
      @base = base
    end
    attr_reader :atom
    attr_reader :base
    ##
    # The integer representation of the atom
    def to_i
      @atom.to_i
    end
    ##
    # The float representation of the atom
    def to_f
      @atom.to_f
    end
    ##
    # The amount of seconds of the atom
    def to_seconds
      @atom * factor
    end
    ##
    # The atom factor to compute the amount of seconds for the atom
    def factor
      raise NotImplementedError, "The #factor method should be implemented by each subclass"
    end
  end
  ##
  # A Years atom in a {ISO8601::Duration}
  #
  # A “calendar year” is the cyclic time interval in a calendar which is
  # required for one revolution of the Earth around the Sun and approximated to
  # an integral number of “calendar days”.
  #
  # A “duration year” is the duration of 365 or 366 “calendar days” depending on
  # the start and/or the end of the corresponding time interval within the
  # specific “calendar year”.
  class Years < ISO8601::Atom
    ##
    # The Year factor
    #
    # The “duration year” average is calculated through time intervals of 400
    # “duration years”. Each cycle of 400 “duration years” has 303 “common
    # years” of 365 “calendar days” and 97 “leap years” of 366 “calendar days”.
    def factor
      if @base.nil?
        ((365 * 303 + 366 * 97) / 400) * 86400
      elsif @atom == 0
        year = (@base.year).to_i
        (::Time.utc(year) - ::Time.utc(@base.year))
      else
        year = (@base.year + @atom).to_i
        (::Time.utc(year) - ::Time.utc(@base.year)) / @atom
      end
    end
    ##
    # Returns the ISO 8601 representation for the atom
    #
    # @return [String]
    def to_s
      (atom.zero?) ? '' : "#{atom}Y"
    end
  end
  ##
  # A Months atom in a {ISO8601::Duration}
  #
  # A “calendar month” is the time interval resulting from the division of a
  # “calendar year” in 12 time intervals.
  #
  # A “duration month” is the duration of 28, 29, 30 or 31 “calendar days”
  # depending on the start and/or the end of the corresponding time interval
  # within the specific “calendar month”.
  class Months < ISO8601::Atom
    ##
    # The Month factor
    #
    # The “duration month” average is calculated through time intervals of 400
    # “duration years”. Each cycle of 400 “duration years” has 303 “common
    # years” of 365 “calendar days” and 97 “leap years” of 366 “calendar days”.
    def factor
      if @base.nil?
        nobase_calculation
      elsif @atom == 0
        zero_calculation
      else
        calculation
      end
    end
    ##
    # Returns the ISO 8601 representation for the atom
    #
    # @return [String]
    def to_s
      (atom.zero?) ? '' : "#{atom}M"
    end

    private

    def nobase_calculation
      (((365 * 303 + 366 * 97) / 400) * 86400) / 12
    end

    def zero_calculation
      month = (@base.month <= 12) ? (@base.month) : ((@base.month) % 12)
      year = @base.year + ((@base.month) / 12).to_i

      (::Time.utc(year, month) - ::Time.utc(@base.year, @base.month))
    end

    def calculation
      if @base.month + @atom <= 0
        month = @base.month + @atom

        if month % 12 == 0
          year = @base.year + (month / 12) - 1
          month = 12
        else
          year = @base.year + (month / 12).floor
          month = (12 + month > 0) ? (12 + month) : (12 + (month % -12))
        end
      else
        month = (@base.month + @atom <= 12) ? (@base.month + @atom) : ((@base.month + @atom) % 12)
        month = 12 if month == 0
        year = @base.year + ((@base.month + @atom) / 12).to_i
      end

      (::Time.utc(year, month) - ::Time.utc(@base.year, @base.month)) / @atom
    end
  end
  ##
  # A Weeks atom in a {ISO8601::Duration}
  class Weeks < ISO8601::Atom
    ##
    # The Week factor
    def factor
      604800
    end
    ##
    # Returns the ISO 8601 representation for the atom
    #
    # @return [String]
    def to_s
      (atom.zero?) ? '' : "#{atom}W"
    end
  end
  ##
  # The Days atom in a {ISO8601::Duration}
  #
  # A “calendar day” is the time interval which starts at a certain time of day
  # at a certain “calendar day” and ends at the same time of day at the next
  # “calendar day”.
  class Days < ISO8601::Atom
    ##
    # The Day factor
    def factor
      86400
    end
    ##
    # Returns the ISO 8601 representation for the atom
    #
    # @return [String]
    def to_s
      (atom.zero?) ? '' : "#{atom}D"
    end
  end
  ##
  # The Hours atom in a {ISO8601::Duration}
  class Hours < ISO8601::Atom
    ##
    # The Hour factor
    def factor
      3600
    end
    ##
    # Returns the ISO 8601 representation for the atom
    #
    # @return [String]
    def to_s
      (atom.zero?) ? '' : "#{atom}H"
    end
  end
  ##
  # The Minutes atom in a {ISO8601::Duration}
  class Minutes < ISO8601::Atom
    ##
    # The Minute factor
    def factor
      60
    end
    ##
    # Returns the ISO 8601 representation for the atom
    #
    # @return [String]
    def to_s
      (atom.zero?) ? '' : "#{atom}M"
    end
  end
  ##
  # The Seconds atom in a {ISO8601::Duration}
  #
  # The second is the base unit of measurement of time in the International
  # System of Units (SI) as defined by the International Committee of Weights
  # and Measures (CIPM, i.e. Comité International des Poids et Mesures)
  class Seconds < ISO8601::Atom
    ##
    # The Second factor
    def factor
      1
    end
    ##
    # Returns the ISO 8601 representation for the atom
    #
    # @return [String]
    def to_s
      (atom.zero?) ? '' : "#{atom}S"
    end
  end
end
