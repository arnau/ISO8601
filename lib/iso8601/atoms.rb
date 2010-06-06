module ISO8601

  # Represents a generic atom in a +ISO8601::Duration+.
  class Atom
    def initialize(atom, base=nil)
      is_integer?(atom, "First argument for #{self.inspect} must be an Integer.")
      @atom = atom
      @base = base
    end

    def to_i
      @atom
    end
    def to_seconds
      @atom.to_f * self.factor
    end

    private
      def is_integer?(arg, error_message=nil)
        if !arg.is_a? Integer
          raise TypeError, error_message
        end
      end
  end

  # A “calendar year” is the cyclic time interval in a calendar which is
  # required for one revolution of the Earth around the Sun and approximated to
  # an integral number of “calendar days”.
  
  #A “duration year” is the duration of 365 or 366 “calendar days” depending on
  # the start and/or the end of the corresponding time interval within the
  # specific “calendar year”.
  class Years < ISO8601::Atom
    
    # The “duration year” average is calculated through time intervals of 400
    # “duration years”. Each cycle of 400 “duration years” has 303 “common
    # years” of 365 “calendar days” and 97 “leap years” of 366 “calendar days”.
    def factor
      if @base.nil?
        ((365 * 303 + 366 * 97) / 400) * 86400
      else
        Time.parse("#{@base.year + 1}-01-01") - Time.parse("#{@base.year}-01-01")
      end
    end
  end
  
  # A “calendar month” is the time interval resulting from the division of a
  # “calendar year” in 12 time intervals.

  # A “duration month” is the duration of 28, 29, 30 or 31 “calendar days”
  # depending on the start and/or the end of the corresponding time interval
  # within the specific “calendar month”.
  class Months < ISO8601::Atom

    # The “duration month” average is calculated through time intervals of 400
    # “duration years”. Each cycle of 400 “duration years” has 303 “common
    # years” of 365 “calendar days” and 97 “leap years” of 366 “calendar days”.
    def factor
      if @base.nil?
        (((365 * 303 + 366 * 97) / 400) * 86400) / 12
      else
        (Time.parse("#{@base.year + 1}-01-01") - Time.parse("#{@base.year}-01-01")) / 12
      end
    end
  end
  
  # A “calendar day” is the time interval which starts at a certain time of day
  # at a certain “calendar day” and ends at the same time of day at the next
  # “calendar day”.
  class Days < ISO8601::Atom
    
    # A day is equal to 86400 seconds.
    def factor
      86400
    end
  end
  
  class Hours < ISO8601::Atom
    
    # An hour is equal to 3600 seconds.
    def factor
      3600
    end
  end
  class Minutes < ISO8601::Atom

    # A minute is equal to 60 seconds.
    def factor
      60
    end
  end
  
  # The second is the base unit of measurement of time in the International
  # System of Units (SI) as defined by the International Committee of Weights
  # and Measures (CIPM, i.e. Comité International des Poids et Mesures)
  class Seconds < ISO8601::Atom
    def factor
      1
    end
  end
end