# encoding: utf-8

module ISO8601
  ##
  # The Hours atom in a {ISO8601::Duration}
  class Hours
    include Atomic

    AVERAGE_FACTOR = 3600

    ##
    # @param [Numeric] atom The atom value
    def initialize(atom)
      valid_atom?(atom)

      @atom = atom
    end

    ##
    # The Week factor
    #
    # @param [ISO8601::DateTime, nil] base (nil) The base datetime to compute
    #   the month length.
    #
    # @return [Numeric]
    def factor(base = nil)
      AVERAGE_FACTOR
    end

    ##
    # The amount of seconds
    #
    # @param [ISO8601::DateTime, nil] base (nil) The base datetime to compute
    #   the month length.
    #
    # @return [Numeric]
    def to_seconds(base = nil)
      AVERAGE_FACTOR * atom
    end

    ##
    # The atom symbol.
    #
    # @return [Symbol]
    def symbol
      :H
    end
  end
end
