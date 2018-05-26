class BankTransfer::InwardInvoices::Create < BankTransfer::InwardInvoices::Base

  attr_accessor :inward_invoice, :inward_invoice_parameters

  def init
    self.inward_invoice_parameters = invoice_attributes
  end

  def validate

  end

  def pre_process
    # setting the receiving_account type as 'BankAccount' for now, can support other oprtions later
    self.inward_invoice_parameters[:receiving_account_type] = "BankAccount"
  end

  def process
    self.inward_invoice = user.company.inward_invoices.build(self.inward_invoice_parameters)
    # assign the attributes to the invoice and calculate the various amounts
    calculate_tax_and_discounts(self.inward_invoice, self.inward_invoice_parameters)
    unless self.inward_invoice.save
      add_message :error, self.inward_invoice.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Invoice successfully created"
  end
end