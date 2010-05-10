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

    private
      def is_integer?(arg, error_message=nil)
        if arg.integer?
          if arg < 0
            raise RangeError, error_message
          end
        else
          raise TypeError, error_message
        end
      rescue NoMethodError => e
        raise TypeError, error_message
      end
      def factor(f)
        # factor to calculate conversions
        if @base.nil?
          f
        else
          raise TypeError, "Base date not yet implemented."
        end
      end
  end

  class Years < ISO8601::Atom
    def to_seconds
      @atom.to_f * factor(((365 * 303 + 366 * 97) / 400) * 86400)
    end
    
  end

  class Months < ISO8601::Atom
    def to_seconds
      @atom.to_f * factor((((365 * 303 + 366 * 97) / 400) * 86400) / 12)
    end
  end

  class Days < ISO8601::Atom
    def to_seconds
      @atom.to_f * factor(86400)
    end
  end
  class Hours < ISO8601::Atom
    def to_seconds
      @atom.to_f * factor(3600)
    end
  end
  class Minutes < ISO8601::Atom
    def to_seconds
      @atom.to_f * factor(60)
    end
  end
  class Seconds < ISO8601::Atom
    def to_seconds
      @atom.to_f * factor(1)
    end
  end
end