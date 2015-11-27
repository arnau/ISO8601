# encoding: utf-8

module ISO8601
  ##
  # A Weeks atom in a {ISO8601::Duration}
  class Weeks < ISO8601::Atom
    ##
    # The Week factor
    def factor
      604800
    end

    ##
    # The atom symbol.
    #
    # @return [Symbol]
    def symbol
      :W
    end
  end
end
