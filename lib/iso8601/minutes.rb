# encoding: utf-8

module ISO8601
  ##
  # The Minutes atom in a {ISO8601::Duration}
  class Minutes < ISO8601::Atom
    ##
    # The Minute factor
    def factor
      60
    end

    ##
    # The atom symbol.
    #
    # @return [Symbol]
    def symbol
      :M
    end
  end
end
