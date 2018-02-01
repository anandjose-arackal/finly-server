# operation that updates the respective virtual account associated with a particular invoice
class Invoicing::Invoice::VirtualAccount::Update < Invoicing::Invoice::Base

  attr_accessor :invoice, :virtual_account

  def init
    invoice_id = params[:id] || params[:invoice_id] || params[:outward_invoice_id]
    self.invoice = user.company.outward_invoices.find_by(id: invoice_id)
    virtual_account_id = params[:virtual_account_id]
    self.virtual_account = user.company.virtual_bank_accounts.find_by(id: virtual_account_id)
  end

  def validate
    if self.invoice.blank?
      add_message :error, "Invoice not found"
      return
    end

    if self.virtual_account.blank?
      add_message :error, "Virtual bank account not found"
      return
    end

    # check if this particular virtual account belongs to the right customer
    if self.invoice.customer.present?
      if self.virtual_account.customer_id != self.invoice.customer.id
        add_message :error, "This virtual account does not belong to the invoice's customer"
        return
      end
    end
  end

  def process
    unless self.virtual_account.update(parent: self.invoice, purpose_id: VirtualAccountPurpose.id_for(:invoice))
      add_message :error, self.virtual_account.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Virtual account updated!"
  end

end