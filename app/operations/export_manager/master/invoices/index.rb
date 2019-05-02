class ExportManager::Master::Invoices::Index < ExportManager::Master::BaseMaster
  attr_accessor :input_data

  register_handle :invoices
  register_generator ExportManager::Generator::Spreadsheet
  register_processor ExportManager::Processor::Synchronous
  validate :input
  register_fields [
                      finly_ref_no: {spreadsheet: true},
                      #po_number: {spreadsheet: true},
                      invoice_type: {spreadsheet: true},
                      invoice_number: {spreadsheet: true},
                      invoice_date: {spreadsheet: true},
                      vendor_name: {spreadsheet: true},
                      vendor_ref_num: {spreadsheet: true},
                      #added_by: {spreadsheet: true},
                      total_amount: {spreadsheet: true},
                      total_payable: {spreadsheet: true},
                      total_tax: {spreadsheet: true},
                      narration: {spreadsheet: true},
                      nature_of_expense: {spreadsheet: true},
                  ]

  def input
    return self.input_data unless self.input_data.nil?

    invoices_presenter = BankTransfer::InwardInvoices::Index.(user, params)

    unless invoices_presenter.success?
      add_message :error, invoices_presenter.messages[:error]
      return
    end

    self.input_data = invoices_presenter.invoices
  end

  def finly_ref_no(invoice)
    invoice.invoice_id
  end

  # def po_number(invoice)
  #   invoice.po_number
  # end

  def invoice_type(invoice)
    invoice.invoice_type&.name
  end

  def invoice_number(invoice)
    invoice.invoice_number
  end

  def invoice_date(invoice)
    invoice.date
  end

  def vendor_name(invoice)
    invoice.vendor&.name
  end

  def vendor_ref_num(invoice)
    invoice.vendor_id
  end

  # def added_by(invoice)
  #   invoice.created_by
  # end

  def total_amount(invoice)
    invoice.amount&.value
  end

  def total_payable(invoice)
    invoice.remaining_amount&.value
  end

  def total_tax(invoice)
    invoice.tax_amount&.value
  end

  # Todo work-around for Swiggy
  def narration(invoice)
    invoice.custom_fields.with_field_key(:narration).first&.string_value
  end

  def nature_of_expense(invoice)
    invoice.custom_fields.with_field_key(:nature_of_expense).first&.string_value
  end
  # Todo work-around for Swiggy

end