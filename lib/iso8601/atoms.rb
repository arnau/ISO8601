module ISO8601
  class Atom
    def initialize(atom, base=nil)
      is_integer?(atom, "First argument for #{self.inspect} must be a positive Integer.")
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
        elsif arg < 0
          raise RangeError, error_message
        end
      end
  end

  class Years < ISO8601::Atom
    def factor
      if @base.nil?
        ((365 * 303 + 366 * 97) / 400) * 86400
      else
        raise TypeError, "Base date not yet implemented."
      end
    end
  end
  class Months < ISO8601::Atom
    def factor
      if @base.nil?
        (((365 * 303 + 366 * 97) / 400) * 86400) / 12
      else
        raise TypeError, "Base date not yet implemented."
      end
    end
  end
  class Days < ISO8601::Atom
    def factor
      86400
    end
  end
  class Hours < ISO8601::Atom
    def factor
      3600
    end
  end
  class Minutes < ISO8601::Atom
    def factor
      60
    end
  end
  class Seconds < ISO8601::Atom
    def factor
      1
    end
  end
end