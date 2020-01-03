class ExportManager::Master::Budgets::UsageEntities < ExportManager::Builders::Spreadsheet

  attr_accessor :entities

  validate :input
  handle :budget_entities

  attribute :entity_name #, column_name: "Entity Name", optional: false
  attribute :entity_type
  attribute :po_number
  attribute :invoice_number
  attribute :payment_id
  attribute :expense_id
  attribute :category
  attribute :department
  attribute :cost_center
  attribute :location
  attribute :amount
  attribute :vendor
  attribute :merchant
  attribute :created_at
  attribute :created_by
  # attribute :custom_fields

  def input
    op = ::Budgets::Show.(user, params)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end
    budget = op.budget
    processor_instance = BudgetsCalculator::Calculate::BudgetsProcessor.new(budget)
    items = processor_instance.spent_entities
    items[0] + items[1] + items[2] + items[3]
  end

  def entity_name(item)
    case item.class.name
    when "PurchaseOrderItem"
      return item.description
    when "InvoiceLineItem"
      return item.description
    when "Payment"
      return "Payment to #{item.entity.receiving_user.name}"
    when "Expense"
      return "Expense at #{item.entity.merchant_name}"
    end
  end

  def entity_type(item)
    item.class.name.underscore.humanize
  end

  def po_number(item)
    if item.is_a?(PurchaseOrderItem)
      return item.purchase_order.po_number
    end
    ""
  end

  def invoice_number(item)
    if item.is_a?(InvoiceLineItem)
      return item.parent.invoice_number
    end
    ""
  end

  def payment_id(item)
    if item.is_a?(Payment)
      return item.id
    end
    ""
  end

  def expense_id(item)
    if item.is_a?(Expense)
      return item.id
    end
    ""
  end

  def department(item)
    if item.is_a?(PurchaseOrderItem)
      return item.purchase_order.department&.name
    elsif item.is_a?(InvoiceLineItem)
      return item.parent.department&.name
    end
    ""
  end

  def cost_center(item)
    if item.is_a?(PurchaseOrderItem)
      return item.purchase_order.cost_center&.name
    elsif item.is_a?(InvoiceLineItem)
      return item.parent.cost_center&.name
    elsif item.is_a?(Payment)
      return item.invoice.cost_center&.name
    end
    ""
  end

  def location(item)
    if item.is_a?(PurchaseOrderItem)
      return item.purchase_order.location&.name
    elsif item.is_a?(InvoiceLineItem)
      return item.parent.location&.name
    elsif item.is_a?(Payment)
      return item.invoice.location&.name
    end
    ""
  end

  def category(item)
    if item.is_a?(PurchaseOrderItem)
      return item.category&.name || item.inventory_line_item&.category&.name
    elsif item.is_a?(InvoiceLineItem)
      return item.category&.name || item.inventory_line_item&.category&.name
    elsif item.is_a?(Payment)
      case item.parent_type
      when "Invoice"
        return item.parent&.category&.name
      when "BeneficiaryPayment"
        return item.parent&.category&.name
      when "PurchaseOrder"
        return ""
      else
        return ""
      end
    end
    ""
  end

  def amount(item)
    if item.is_a?(PurchaseOrderItem)
      return item.total_amount&.value
    elsif item.is_a?(InvoiceLineItem)
      return item.net_amount&.value
    elsif item.is_a?(Payment)
      return item.amount&.value
    elsif item.is_a?(Expense)
      return item.amount&.value
    end
    ""
  end

  def merchant(item)
    if item.is_a?(Expense)
      return item.merchant_name
    end
    ""
  end

  def vendor(item)
    if item.is_a?(PurchaseOrderItem)
      return item.purchase_order.vendor&.name
    elsif item.is_a?(InvoiceLineItem)
      return item.parent.vendor&.name
    elsif item.is_a?(Payment)
      return item.receiving_user&.name
    end
    ""
  end

  def created_at(item)
    item.created_at
  end

  def created_by(item)
    if item.is_a?(PurchaseOrderItem)
      return item.purchase_order.user&.name
    elsif item.is_a?(InvoiceLineItem)
      return item.parent.created_by&.name
    elsif item.is_a?(Payment)
      return item.initiating_user&.name
    elsif item.is_a?(Expense)
      return item.user&.name
    end
    ""
  end
end