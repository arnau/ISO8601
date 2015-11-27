# encoding: utf-8

module ISO8601
  ##
  # The Seconds atom in a {ISO8601::Duration}
  #
  # The second is the base unit of measurement of time in the International
  # System of Units (SI) as defined by the International Committee of Weights
  # and Measures.
  class Seconds < ISO8601::Atom
    ##
    # The Second factor
    def factor
      1
    end

    ##
    # The atom symbol.
    #
    # @return [Symbol]
    def symbol
      :S
    end
  end
end
