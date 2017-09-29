class BankTransfer::Vendors::Count < BankTransfer::Vendors::Base

  attr_accessor :vendors_count

  def init
    self.company = user.company
  end

  def process
    # todo - in the future, with finance and manager view, we can implement team view for vendors and shit
    self.vendors_count = company.yes_bank_vendors.count
  end

  def success
    vendors_count
  end

end