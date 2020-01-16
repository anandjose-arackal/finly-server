class ExportManager::Master::PurchaseOrders::PurchaseOrderItems::Index < ExportManager::Builders::Spreadsheet


  label 'Export'
  description 'Purchase Orders Export'
  configurable true
  system :vp
  # screen 'purchase_orders.index'
  handle :purchase_order_items
  validate :input

  attribute :procurement_name
  attribute :po_number
  attribute :po_date
  attribute :created_by
  attribute :description
  attribute :comment
  attribute :category
  attribute :policy
  attribute :hsn_sac
  attribute :quantity
  attribute :rate
  attribute :discount
  attribute :discount_amount
  attribute :tax
  attribute :tax_amount
  attribute :total_amount

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

  def policy(item)
    item&.purchase_order&.policy&.name
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