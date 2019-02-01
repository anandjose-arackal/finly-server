class ExportManager::Master::PurchaseOrders::PurchaseOrderItems::Index < ExportManager::Master::BaseSubscriber

  bus ExportManager::Master::BaseMaster
  subscribe :purchase_order_items
  generators ExportManager::Generator::Spreadsheet
  processor ExportManager::Processor::Synchronous
  validate :input
  fields [
    procurement_name: {spreadsheet: true, pdf: true},
    po_number: {spreadsheet: true, pdf: true},
    po_date: {spreadsheet: true, pdf: true},
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

    purchase_order_ids = PurchaseOrder.with_procurement_id(procurements.pluck(:id))

    purchase_order_items = PurchaseOrderItem.with_purchase_order_id(purchase_order_ids)

    purchase_order_items
  end

  def procurement_name(item)
    procurement(item)&.name
  end

  def po_number(item)
    purchase_order(item)&.po_number
  end 

  def po_date(item)
    purchase_order(item)&.created_at&.strftime "%d-%b-%Y"
  end 

  def created_by(item)
    purchase_order(item)&.user&.name
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
    value = item.total_amount&.value || 0
    precision_value(value)
  end

  protected
  def purchase_order(item)
    item&.purchase_order
  end

  def procurement(item)
    purchase_order(item)&.procurement
  end

  def inventory_line_item(item)
    item.inventory_line_item
  end


end