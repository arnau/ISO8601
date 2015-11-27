# encoding: utf-8

module ISO8601
  ##
  # A generic atom in a {ISO8601::Duration}
  #
  # @abstract
  class Atom
    include Comparable
    ##
    # @param [Numeric] atom The atom value
    # @param [ISO8601::DateTime, nil] base (nil) The base datetime to compute
    #   the atom factor.
    def initialize(atom, base = nil)
      fail ISO8601::Errors::TypeError,
           "The atom argument for #{self.class} should be a Numeric value." unless atom.is_a?(Numeric)
      fail ISO8601::Errors::TypeError,
           "The base argument for #{self.class} should be a ISO8601::DateTime instance or nil." unless base.is_a?(ISO8601::DateTime) || base.nil?
      @atom = atom
      @base = base
    end

    attr_reader :atom

    attr_reader :base

    ##
    # The integer representation
    #
    # @return [Integer]
    def to_i
      atom.to_i
    end

    ##
    # The float representation
    #
    # @return [Float]
    def to_f
      atom.to_f
    end

    ##
    # Returns the ISO 8601 representation for the atom
    #
    # @return [String]
    def to_s
      (value.zero?) ? '' : "#{value}#{symbol}"
    end

    ##
    # The simplest numeric representation. If modulo equals 0 returns an
    # integer else a float.
    #
    # @return [Numeric]
    def value
      (atom % 1).zero? ? atom.to_i : atom
    end

    ##
    # The amount of seconds
    #
    # @return [Numeric]
    def to_seconds
      atom * factor
    end

    ##
    # @param [Atom] other The contrast to compare against
    #
    # @return [-1, 0, 1]
    def <=>(other)
      return nil unless other.is_a?(self.class)

      to_f <=> other.to_f
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
      [atom, self.class].hash
    end

    ##
    # The atom factor to compute the amount of seconds for the atom
    def factor
      fail NotImplementedError,
           "The #factor method should be implemented by each subclass"
    end
  end
end
