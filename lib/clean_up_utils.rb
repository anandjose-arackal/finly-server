class CleanUpUtils

  def self.mobile_number_cleanup(number)
    # checking for '+91' and '+91-' condition
    if number[0..2] == '+91' && number.size > 10
      if number[3] == '-'
        return number[4..number.size]
      else
        return number[3..number.size]
      end
    end

    # checking for '91' and '91-' condition
    if number[0..1] == '91' && number.size > 10
      if number[2] == '-'
        return number[3..number.size]
      else
        return number[2..number.size]
      end
    end

    # checking for a starting zero - in case of landline numbers
    if number[0] == '0'
      return number[1..number.size]
    end

    return number
  end

end