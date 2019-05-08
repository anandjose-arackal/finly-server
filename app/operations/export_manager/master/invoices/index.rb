# class ExportManager::Master::Invoices::Index < ExportManager::Master::BaseMaster
#   attr_accessor :input_data
#
#   register_handle :invoices
#   register_generator ExportManager::Generator::Spreadsheet
#   register_processor ExportManager::Processor::Synchronous
#   validate :input
#   register_fields [
#                       finly_ref_no: {spreadsheet: true},
#                       #po_number: {spreadsheet: true},
#                       invoice_type: {spreadsheet: true},
#                       invoice_number: {spreadsheet: true},
#                       invoice_date: {spreadsheet: true},
#                       vendor_name: {spreadsheet: true},
#                       vendor_ref_num: {spreadsheet: true},
#                       #added_by: {spreadsheet: true},
#                       total_amount: {spreadsheet: true},
#                       total_payable: {spreadsheet: true},
#                       total_tax: {spreadsheet: true},
#                       narration: {spreadsheet: true},
#                   ]
#
#   def input
#     return self.input_data unless self.input_data.nil?
#
#     invoices_presenter = BankTransfer::InwardInvoices::Index.(user, params)
#
#     unless invoices_presenter.success?
#       add_message :error, invoices_presenter.messages[:error]
#       return
#     end
#
#     self.input_data = invoices_presenter.invoices
#   end
#
#   def finly_ref_no(invoice)
#     invoice.invoice_id
#   end
#
#   # def po_number(invoice)
#   #   invoice.po_number
#   # end
#
#   def invoice_type(invoice)
#     invoice.invoice_type&.name
#   end
#
#   def invoice_number(invoice)
#     invoice.invoice_number
#   end
#
#   def invoice_date(invoice)
#     invoice.date
#   end
#
#   def vendor_name(invoice)
#     invoice.vendor&.name
#   end
#
#   def vendor_ref_num(invoice)
#     invoice.vendor_id
#   end
#
#   # def added_by(invoice)
#   #   invoice.created_by
#   # end
#
#   def total_amount(invoice)
#     invoice.amount&.value
#   end
#
#   def total_payable(invoice)
#     invoice.remaining_amount&.value
#   end
#
#   def total_tax(invoice)
#     invoice.tax_amount&.value
#   end
#
#   def narration(invoice)
#     invoice..narration.first&.string_value
#   end
#
#   def nature_of_expense(invoice)
#     invoice.custom_fields.with_field_key(:nature_of_expense).first&.string_value
#   end
#
# end

class ExportManager::Master::Invoices::Index < ExportManager::Master::BaseMaster
  attr_accessor :input_data

  register_handle :invoices
  register_generator ExportManager::Generator::Spreadsheet
  register_processor ExportManager::Processor::Synchronous
  validate :input
  register_fields [
                      finly_ref_no: {spreadsheet: true},
                      invoice_type: {spreadsheet: true},
                      invoice_no: {spreadsheet: true},
                      vendor_name: {spreadsheet: true},
                      vendor_ref_no: {spreadsheet: true},
                      # vendor_gst: {spreadsheet: true},
                      # po_number: {spreadsheet: true},
                      transaction_period_from: {spreadsheet: true},
                      transaction_period_to: {spreadsheet: true},
                      category: {spreadsheet: true},
                      quantity: {spreadsheet: true},
                      rate: {spreadsheet: true},
                      narration: {spreadsheet: true},
                      city_name: {spreadsheet: true},
                      city_code: {spreadsheet: true},
                      department_name: {spreadsheet: true},
                      department_code: {spreadsheet: true},
                      gst_group: {spreadsheet: true},
                      hsn_sac: {spreadsheet: true},
                      # tds_nature: {spreadsheet: true},
                      cost_center: {spreadsheet: true},
                      nature_of_expense: {spreadsheet: true},
                      nature_of_office: {spreadsheet: true},
                      item_code: {spreadsheet: true},
                      description: {spreadsheet: true},
                      unit_of_measurement: {spreadsheet: true},
                      total_amount: {spreadsheet: true},
                      tax_amount: {spreadsheet: true},
                      tax_rate: {spreadsheet: true},
                  ]

  def input
    return self.input_data unless self.input_data.nil?

    invoices_presenter = BankTransfer::InwardInvoices::Index.(user, params)

    unless invoices_presenter.success?
      add_message :error, invoices_presenter.messages[:error]
      return
    end

    invoices = invoices_presenter.invoices
    self.input_data = InvoiceLineItem.where(parent_type: 'Invoice').where(parent_id: invoices.pluck(:id))
  end

  def invoice_date(invoice_line_item)
    invoice_line_item.parent.date
  end

  def vendor_ref_num(invoice_line_item)
    invoice_line_item.parent.vendor_id
  end

  def total_tax(invoice_line_item)
    invoice_line_item.tax_amount&.value
  end

  def finly_ref_no(invoice_line_item)
    invoice_line_item.parent.invoice_id
  end

  def invoice_type(invoice_line_item)
    invoice_line_item.parent.invoice_type&.name
  end

  def invoice_no(invoice_line_item)
    invoice_line_item.parent.invoice_number
  end

  def vendor_name(invoice_line_item)
    invoice_line_item.parent.vendor&.name
  end

  def vendor_ref_no(invoice_line_item)
    invoice_line_item.parent.vendor.vendor_id
  end

  # def vendor_gst(invoice_line_item)
  #   invoice_line_item
  # end

  # def po_number(invoice_line_item)
  #   invoice_line_item
  # end

  def transaction_period_from(invoice_line_item)
    invoice_line_item.parent.transaction_service_period_from&.strftime("%d-%M-%y")
  end

  def transaction_period_to(invoice_line_item)
    invoice_line_item.parent.transaction_service_period_from&.strftime("%d-%M-%y")
  end

  def category(invoice_line_item)
    invoice_line_item.category&.name
  end

  def quantity(invoice_line_item)
    invoice_line_item.quantity
  end

  def rate(invoice_line_item)
    invoice_line_item&.rate
  end

  def narration(invoice_line_item)
    invoice_line_item.parent.narration
  end

  def city_name(invoice_line_item)
    invoice_line_item.parent.location&.name
  end

  def city_code(invoice_line_item)
    invoice_line_item.parent.location&.location_code
  end

  def department_name(invoice_line_item)
    invoice_line_item.department&.name
  end

  def department_code(invoice_line_item)
    invoice_line_item.department&.department_code
  end

  def gst_group(invoice_line_item)
    invoice_line_item&.tax_rate&.name
  end

  def hsn_sac(invoice_line_item)
    invoice_line_item.hsn_sac
  end

  # def tds_nature(invoice_line_item)
  #   invoice_line_item
  # end

  def cost_center(invoice_line_item)
    invoice_line_item.cost_center&.name
  end

  def nature_of_expense(invoice_line_item)
    invoice_line_item.parent.custom_fields.with_field_key(:nature_of_expense).first&.string_value
  end

  def nature_of_office(invoice_line_item)
    invoice_line_item.parent.custom_fields.with_field_key(:nature_of_office).first&.string_value
  end

  def item_code(invoice_line_item)
    invoice_line_item.inventory_line_item&.item_code
  end

  def description(invoice_line_item)
    invoice_line_item.description
  end

  def unit_of_measurement(invoice_line_item)
    invoice_line_item.unit_of_measurement
  end

  def total_amount(invoice_line_item)
    invoice_line_item.amount&.value
  end

  def tax_amount(invoice_line_item)
    invoice_line_item.tax_amount&.value
  end

  def tax_rate(invoice_line_item)
    invoice_line_item.tax_rate&.rate
  end


end