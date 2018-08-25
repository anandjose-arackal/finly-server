class BankTransfer::InwardInvoices::Count < BankTransfer::InwardInvoices::Base

  attr_accessor :count

  def init
    op = BankTransfer::InwardInvoices::Index.(user, params)
    if op.success?
      self.count = op.invoices.count
    else
      self.count = 0
    end
  end

  def success
    self.count
  end
end