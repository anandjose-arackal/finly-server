class ExportManager::Master::Budgets::UsageEntities < ExportManager::Master::BaseMaster

  attr_accessor :entities

  register_handle :budget_entities
  register_generator ExportManager::Generator::Spreadsheet
  register_processor ExportManager::Processor::Synchronous
  validate :input
  register_fields [
                      entity_name: {spreadsheet: true, pdf: false},
                      entity_type: {spreadsheet: true, pdf: false},
                      po_number: {spreadsheet: true, pdf: false},
                      invoice_number: {spreadsheet: true, pdf: false},
                      payment_id: {spreadsheet: true, pdf: false},
                      expense_id: {spreadsheet: true, pdf: false},
                      category: {spreadsheet: true, pdf: false},
                      department: {spreadsheet: true, pdf: false},
                      cost_center: {spreadsheet: true, pdf: false},
                      location: {spreadsheet: true, pdf: false},
                      amount: {spreadsheet: true, pdf: false},
                      vendor: {spreadsheet: true, pdf: false},
                      merchant: {spreadsheet: true, pdf: false},
                      created_at: {spreadsheet: true, pdf: false},
                      created_by: {spreadsheet: true, pdf: false}
                  ]

  def input
    op = Budgets::Show.(user, params)
    unless op.success?
      add_message :error, result.messages[:error]
      return
    end
    budget = op.budget
    processor_instance = BudgetsCalculator::Calculate::BudgetsProcessor.new(budget)
    items = processor_instance.spent_entities
    all_items = items[0] + items[1] + items[2] + items[3]
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

  def category(item)
    if item.is_a?(PurchaseOrderItem)
      return item.category&.name
    elsif item.is_a?(InvoiceLineItem)
      return item.category&.name
    elsif item.is_a?(Payment)
      return item.invoice.category&.name
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
      return item.parent.created_by_user&.name
    elsif item.is_a?(Payment)
      return item.initiating_user&.name
    elsif item.is_a?(Expense)
      return item.user&.name
    end
    ""
  end
end