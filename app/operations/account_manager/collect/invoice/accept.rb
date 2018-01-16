class AccountManager::Collect::Invoice::Accept < AccountManager::Collect::Invoice::Base

  attr_accessor :virtual_account, :company, :outward_invoice, :payment, :virtual_account_transaction

  def init
    self.virtual_account_transaction = params[:virtual_account_transaction]
    self.virtual_account = virtual_account_transaction.virtual_account
    self.company = virtual_account.company
    self.outward_invoice = self.virtual_account.parent
  end

  def validate
    # ensure that the invoice is still in an unpaid state
    unless self.outward_invoice.unpaid? || self.outward_invoice.partially_paid?
      add_message :error, "Only unpaid or partially paid invoices can accept payments"
      return
    end

  end

  def process

  end


end