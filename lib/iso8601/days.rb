# encoding: utf-8

module ISO8601
  ##
  # The Days atom in a {ISO8601::Duration}
  #
  # A "calendar day" is the time interval which starts at a certain time of day
  # at a certain "calendar day" and ends at the same time of day at the next
  # "calendar day".
  class Days < ISO8601::Atom
    ##
    # The Day factor
    def factor
      86400
    end

    ##
    # The atom symbol.
    #
    # @return [Symbol]
    def symbol
      :D
    end
  end
end
