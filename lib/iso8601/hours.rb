# encoding: utf-8

module ISO8601
  ##
  # The Hours atom in a {ISO8601::Duration}
  class Hours < ISO8601::Atom
    ##
    # The Hour factor
    def factor
      3600
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
