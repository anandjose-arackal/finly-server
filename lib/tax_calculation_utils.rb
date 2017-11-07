# the library that will be used for all tax calculations
class TaxCalculationUtils

  # type - will be 1 for rate, and 2 for absolute amounts
  def self.exclusive_tax_amount(amount = 0, tax = 0, type = 1)
    if amount == 0 || tax == 0
      return amount
    end
    if amount.blank? || tax.blank?
      return amount
    end
    case type
      when 1, '1'
        amount = amount + (amount*tax)/100
      when 2, '2'
        amount = amount + tax
      else
        # default is assumed as rate
        amount = amount + (amount*tax)/100
    end
    amount
  end

  # this returns the gross amount of the
  def self.inclusive_tax_amount(amount = 0, tax = 0, type = 1)
    if amount == 0 || tax == 0
      return amount
    end
    if amount.blank? || tax.blank?
      return amount
    end
    case type
      when 1, '1'
        amount = (amount * 100) / (100 + tax)
      when 2, '2'
        amount = amount - tax
      else
        # default is assumed as rate
        amount = (amount * 100) / (100 + tax)
    end
    amount
  end

  # this is always a deduction, so nothing much to do here
  def self.tds_amount(amount = 0, tax = 0, type = 1)
    if amount == 0 || tax == 0
      return amount
    end
    if amount.blank? || tax.blank?
      return amount
    end
    case type
      when 1, '1'
        amount = amount - (amount*tax)/100
      when 2, '2'
        amount = amount - tax
      else
        # default is assumed as rate
        amount = amount - (amount*tax)/100
    end
    amount
  end

end