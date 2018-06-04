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
    self.inward_invoice_parameters[:invoice_status_id] = InwardInvoiceStatus.id_for(:unpaid)
  end

  def process
    self.inward_invoice = user.company.inward_invoices.build(self.inward_invoice_parameters)
    # assign the attributes to the invoice and calculate the various amounts
    calculate_tax_and_discounts(self.inward_invoice, self.inward_invoice_parameters)
    op = validate_custom_fields_invoice
    unless op.success?
      add_message :error, op.messages[:error]
    end
    unless self.inward_invoice.save
      add_message :error, self.inward_invoice.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Invoice successfully created"
  end

  private

  def validate_custom_fields_invoice
    set_fields = set_custom_fields_invoice self.inward_invoice, self.inward_invoice_parameters[:custom_fields], false
    unless set_fields.success?
      add_message :error, set_fields.messages[:error]
      return
    end
    valid = CustomField::Validate.(self.inward_invoice)
    unless valid.success?
      add_message :error, valid.messages[:error]
      return
    end
  end

  def set_custom_fields_invoice(invoice, data, save)
    custom_fields = {custom_fields: data}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = true
    custom_fields[:save] = save
    CustomField::SetFields.(invoice, FieldParentType.id_for(:invoice), custom_fields)
  end
end