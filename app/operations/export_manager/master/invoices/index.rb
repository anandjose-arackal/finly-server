# class ExportManager::Master::Invoices::Index < ExportManager::Master::BaseSubscriber
#   attr_accessor :input_data
#
#   bus ExportManager::Master::BaseMaster
#   subscribe :invoices
#   generators ExportManager::Generator::Spreadsheet
#   processor ExportManager::Processor::Synchronous
#   validate :input
#   fields [
#              finly_ref_no: {spreadsheet: true},
#              #po_number: {spreadsheet: true},
#              invoice_type: {spreadsheet: true},
#              invoice_number: {spreadsheet: true},
#              invoice_date: {spreadsheet: true},
#              vendor_name: {spreadsheet: true},
#              vendor_ref_num: {spreadsheet: true},
#              #added_by: {spreadsheet: true},
#              total_amount: {spreadsheet: true},
#              total_payable: {spreadsheet: true},
#              total_tax: {spreadsheet: true},
#              narration: {spreadsheet: true},
#              nature_of_expense: {spreadsheet: true},
#          ]
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
#   # Todo work-around for Swiggy
#   def narration(invoice)
#     invoice.custom_fields.with_field_key(:narration).first&.string_value
#   end
#
#   def nature_of_expense(invoice)
#     invoice.custom_fields.with_field_key(:nature_of_expense).first&.string_value
#   end
#   # Todo work-around for Swiggy
#
# end

class ExportManager::Master::Invoices::Index < ExportManager::Master::BaseSubscriber
  attr_accessor :input_data

  bus ExportManager::Master::BaseMaster
  subscribe :invoices
  generators ExportManager::Generator::Spreadsheet
  processor ExportManager::Processor::Synchronous
  validate :input
  fields [
             finly_ref_no: {spreadsheet: true},
             po_number: {spreadsheet: true},
             invoice_type: {spreadsheet: true},
             invoice_no: {spreadsheet: true},
             invoice_date: {spreadsheet: true},
             created_by: {spreadsheet: true},
             vendor_name: {spreadsheet: true},
             vendor_ref_no: {spreadsheet: true},
             delivery_location: {spreadsheet: true},
             # vendor_gst: {spreadsheet: true},
             # po_number: {spreadsheet: true},
             transaction_period_from: {spreadsheet: true},
             transaction_period_to: {spreadsheet: true},
             is_invoice_approved: {spreadsheet: true},
             invoice_status: {spreadsheet: true},
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
             tds_nature: {spreadsheet: true},
             tds_percentage: {spreadsheet: true},
             tds_amount: {spreadsheet: true},
             cost_center: {spreadsheet: true},
             nature_of_expense: {spreadsheet: true},
             nature_of_office: {spreadsheet: true},
             item_code: {spreadsheet: true},
             description: {spreadsheet: true},
             unit_of_measurement: {spreadsheet: true},
             total_amount: {spreadsheet: true},
             tax_amount: {spreadsheet: true},
             tax_rate: {spreadsheet: true},
             tax_type: {spreadsheet: true},
             sgst: {spreadsheet: true},
             cgst: {spreadsheet: true},
             igst: {spreadsheet: true},
             advance_amount: {spreadsheet: true},
             invoice_net_payable_amount: {spreadsheet: true},
             approvers: {spreadsheet: true},
             finance_approved_date: {spreadsheet: true}
         ]

  def input
    return self.input_data unless self.input_data.nil?

    invoices_presenter = BankTransfer::InwardInvoices::Index.(user, params)

    unless invoices_presenter.success?
      add_message :error, invoices_presenter.messages[:error]
      return
    end

    invoices = invoices_presenter.invoices
    self.input_data = InvoiceLineItem.where(parent_type: 'Invoice').includes(:category,:department,:tax_rate,:cost_center, :inventory_line_item, {amount: :currency}, {tax_amount: :currency},parent: [:invoice_type,:vendor,:delivery_location,:invoice_status,:location,:tds_slab,:advance_amount,:balance_due,:created_by, {dlrms: [:reviewer,:taken_control_by, :forwarded_to]},{custom_fields: [:value, :field_configuration]},{tds_amount: :currency},:amount,{procurement: :purchase_order}]).where(parent_id: invoices.pluck(:id))
  end

  def po_number(invoice_line_item)
    invoice_line_item.parent&.procurement&.purchase_order&.po_number
  end

  def invoice_date(invoice_line_item)
    invoice_line_item.parent.date
  end

  def delivery_location(invoice_line_item)
    invoice_line_item.parent.delivery_location&.name
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
    # [:tax_invoice, :advance, :non_po_invoice, :beneficiary, :proforma_invoice]
    case invoice_line_item.parent.invoice_type&.name
    when 'tax_invoice'
      "PO Invoice"
    when 'non_po_invoice'
      "NON PO Invoice"
    when 'proforma_invoice'
      "Proforma Invoice"
    else
      "Invoice"
    end
  end

  def invoice_no(invoice_line_item)
    invoice_line_item.parent.invoice_number
  end

  def vendor_name(invoice_line_item)
    invoice_line_item.parent.vendor&.display_name
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
    invoice_line_item.parent.transaction_service_period_from&.strftime("%d-%m-%y")
  end

  def transaction_period_to(invoice_line_item)
    invoice_line_item.parent.transaction_service_period_from&.strftime("%d-%m-%y")
  end

  def invoice_status(invoice_line_item)
    invoice_line_item.parent&.status&.name&.humanize
  end

  def is_invoice_approved(invoice_line_item)
    InwardInvoiceStatus.ids_for(:unpaid, :partially_paid, :paid, :approved, :auto_approved, :closed, :pending, :initiated).include?(invoice_line_item.parent&.invoice_status_id) ? 'Yes' : 'No'
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
    invoice_line_item.parent.custom_fields.map { |cf| cf.string_value if cf.field_key == 'nature_of_expense' }&.first
  end

  def nature_of_office(invoice_line_item)
    invoice_line_item.parent.custom_fields.map { |cf| cf.string_value if cf.field_key == 'nature_of_office' }&.first
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

  def tax_type(invoice_line_item)
    invoice_line_item.tax_rate&.name
  end

  def tds_nature(invoice_line_item)
    invoice_line_item.parent.tds_slab&.name
  end

  def tds_amount(invoice_line_item)
    invoice_line_item.parent.tds_amount&.value || 0
  end

  def tds_percentage(invoice_line_item)
    invoice_line_item.parent.tds_slab&.tds || 0
  end

  def sgst(invoice_line_item)
    invoice_line_item.parent.invoice_items.map {|item| item.sgst.to_i}.compact.sum rescue 0
  end

  def cgst(invoice_line_item)
    invoice_line_item.parent.invoice_items.map {|item| item.cgst.to_i}.compact.sum rescue 0
  end

  def igst(invoice_line_item)
    invoice_line_item.parent.invoice_items.map {|item| item.igst.to_i}.compact.sum rescue 0
  end

  def advance_amount(invoice_line_item)
    value = invoice_line_item.parent&.advance_amount || 0
    precision_value(value)
  end

  def approvers(invoice_line_item)
    approvers = invoice_line_item.parent.dlrms.map do |dlrm|
      taken_control_by = forwarded_to = reviewer = nil
      taken_control_by = dlrm.taken_control_by
      forwarded_to = dlrm.forwarded_to
      reviewer = dlrm.reviewer
      if forwarded_to.present?
        forwarded_to.name
      elsif taken_control_by.present?
        taken_control_by.name
      elsif reviewer.present?
        reviewer.name
      end
    end
    approvers.reject { |e| e.to_s.empty? }.join(", ")
  end

  def invoice_net_payable_amount(invoice_line_item)
    invoice_line_item.parent&.balance_due&.value || 0
  end

  def finance_approved_date(invoice_line_item)
    invoice_line_item.parent&.approved_at&.strftime("%d-%m-%y")
  end

  def created_by(invoice_line_item)
    invoice_line_item.parent&.created_by&.name
  end

end