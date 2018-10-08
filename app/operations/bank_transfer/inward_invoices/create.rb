class BankTransfer::InwardInvoices::Create < BankTransfer::InwardInvoices::Base

  attr_accessor :inward_invoice, :inward_invoice_parameters, :custom_fields

  def init
    self.inward_invoice_parameters = invoice_attributes
    self.custom_fields = params&.dig(:invoice, :custom_fields)
  end

  def validate

  end

  def pre_process
    # setting the receiving_account type as 'BankAccount' for now, can support other oprtions later
    self.inward_invoice_parameters[:receiving_account_type] = "BankAccount"
    self.inward_invoice_parameters[:invoice_status_id] = InwardInvoiceStatus.id_for(:unpaid)

    # removing the remove_file attribute from invoice attachments
    if self.inward_invoice_parameters&.dig(:invoice_attachments_attributes).present?
      self.inward_invoice_parameters[:invoice_attachments_attributes].each do |attachment_params|
        attachment_params.delete(:remove_file)
      end
    end
  end

  def process
    if params[:template_id].present?
      load_invoice_from_template
    else
      self.inward_invoice = user.company.inward_invoices.build(self.inward_invoice_parameters)
    end
    # assign the attributes to the invoice and calculate the various amounts
    calculate_tax_and_discounts(self.inward_invoice, self.inward_invoice_parameters)

    validate_custom_fields_invoice
    return if has_errors?
    unless self.inward_invoice.save
      add_message :error, self.inward_invoice.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Invoice successfully created"
  end

  def success
    params[:inward_invoice] = self.inward_invoice
    BankTransfer::InwardInvoices::Show::InvoicePresenter.new(user, params, messages)
  end
  
  protected

  def load_invoice_from_template
    result = Procurements::Invoices::Templates::Show.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.template = result.template
    self.purchase_order = self.template.amoeba_dup
  end


end