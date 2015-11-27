# encoding: utf-8

module ISO8601
  ##
  # A Months atom in a {ISO8601::Duration}
  #
  # A "calendar month" is the time interval resulting from the division of a
  # "calendar year" in 12 time intervals.
  #
  # A "duration month" is the duration of 28, 29, 30 or 31 "calendar days"
  # depending on the start and/or the end of the corresponding time interval
  # within the specific "calendar month".
  class Months < ISO8601::Atom
    ##
    # The Month factor
    #
    # The "duration month" average is calculated through time intervals of 400
    # "duration years". Each cycle of 400 "duration years" has 303 "common
    # years" of 365 "calendar days" and 97 "leap years" of 366 "calendar days".
    def factor
      if base.nil?
        nobase_calculation
      elsif atom.zero?
        zero_calculation
      else
        calculation
      end
    end

    ##
    # The atom symbol.
    #
    # @return [Symbol]
    def symbol
      :M
    end

    private

    def nobase_calculation
      (((365 * 303 + 366 * 97) / 400) * 86400) / 12
    end

    def zero_calculation
      month = (base.month <= 12) ? base.month : (base.month % 12)
      year = base.year + ((base.month) / 12).to_i

      (::Time.utc(year, month) - ::Time.utc(base.year, base.month))
    end

    def calculation
      initial = base.month + atom
      if initial <= 0
        month = base.month + atom

        if initial % 12 == 0
          year = base.year + (initial / 12) - 1
          month = 12
        else
          year = base.year + (initial / 12).floor
          month = (12 + initial > 0) ? (12 + initial) : (12 + (initial % -12))
        end
      else
        month = (initial <= 12) ? initial : (initial % 12)
        month = 12 if month.zero?
        year = base.year + ((base.month + atom) / 12).to_i
      end

      (::Time.utc(year, month) - ::Time.utc(base.year, base.month)) / atom
    end
  end
end
