class ExportManager::Master::Invoices::InvoiceLineItems::Index < ExportManager::Master::BaseMaster

  register_master ExportManager::Master::BaseMaster
  register :handle, :non_po_items
  register :generator, ExportManager::Generator::Spreadsheet
  register :processor, ExportManager::Processor::Synchronous
  validate :input
  register :fields, [
    procurement_name: {spreadsheet: true, pdf: true},
    invoice_id: {spreadsheet: true, pdf: true},
    invoice_number: {spreadsheet: true, pdf: true},
    invoice_date: {spreadsheet: true, pdf: true},
    created_by: {spreadsheet: true, pdf: true},
    description: {spreadsheet: true, pdf: true},
    comment: {spreadsheet: true, pdf: true},
    category: {spreadsheet: true, pdf: true},
    hsn_sac: {spreadsheet: true, pdf: true},
    quantity: {spreadsheet: true, pdf: true},
    rate: {spreadsheet: true, pdf: true},
    discount: {spreadsheet: true, pdf: true},
    discount_amount: {spreadsheet: true, pdf: true},
    tax: {spreadsheet: true, pdf: true},
    tax_amount: {spreadsheet: true, pdf: true},
    total_amount: {spreadsheet: true, pdf: true}                
  ]

  def input
    procurements_op = ::Procurements::Index.(user, params)

    unless procurements_op.success?
      add_message :error, procurements_op.messages[:error]
      return
    end

    procurements = procurements_op.procurements

    invoices = Invoice.with_procurement_id(procurements.pluck(:id))

    invoice_line_items = InvoiceLineItem.with_parent_type('Invoice').with_parent_id(invoices.pluck(:id))

    invoice_line_items
  end

  def procurement_name(item)
    procurement(item)&.name
  end

  def invoice_id(item)
    invoice(item)&.invoice_id
  end 

  def invoice_number(item)
    invoice(item)&.invoice_number
  end

  def invoice_date(item)
    invoice(item)&.date&.strftime "%d-%b-%Y"
  end 

  def created_by(item)
    invoice(item)&.created_by&.name
  end

  def description(item)
    item.description
  end

  def comment(item)
    item.comment
  end

  def category(item)
    inventory_line_item(item)&.category&.name
  end

  def hsn_sac(item)
    item.hsn_sac
  end

  def quantity(item)
    item.quantity
  end

  def rate(item)
    item.rate
  end

  def tax(item)
    item.tax_rate&.rate || 0
  end

  def tax_amount(item)
    value = item.tax_amount&.value || 0
    precision_value(value)
  end

  def discount(item)
    item.discount || 0
  end

  def discount_amount(item)
    value = item.discount_amount&.value || 0
    precision_value(value)
  end

  def total_amount(item)
    value = item.net_amount&.value || 0
    precision_value(value)
  end

  protected
  def invoice(item)
    item&.parent
  end

  def procurement(item)
    invoice(item)&.procurement
  end

  def inventory_line_item(item)
    item.inventory_line_item
  end
end