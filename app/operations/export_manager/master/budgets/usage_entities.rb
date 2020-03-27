class ExportManager::Master::Budgets::UsageEntities < ExportManager::Builders::Spreadsheet

  attr_accessor :entities, :budget_trails

  description 'Budget Trails Export'
  configurable true
  system :fi
  screen ['budget_group_criteria.index']
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
  attribute :pending_amount
  attribute :committed_amount
  attribute :payment_processing_amount
  attribute :paid_amount
  attribute :vendor
  attribute :merchant
  attribute :created_at
  attribute :submitted_at
  attribute :created_by

  def input
    budget_id = params[:budget_id]
    op = ::BudgetManager::BudgetsTrb::Ops::Show.(params: {id: budget_id}, "current_user" => user, calculate_buckets: false)
    unless op.success?
      add_message :error, op.messages[:error]
      return
    end
    budget = op["model"]
    calculator = ::BudgetManager::BudgetsCalculator::Calculate::BudgetsComputer.({budget: budget, current_user: User.first, calculate_buckets: false, calculate_trail_items: true})
    self.budget_trails = calculator["result"][:budget_trails]
    return self.budget_trails
  end

  def entity_name(item)
    case item.entity_type
    when "PurchaseOrderItem"
      return item.entity.description
    when "InvoiceLineItem"
      return item.entity.description
    when "Payment"
      return "Payment to #{item.entity.receiving_user.name}"
    when "Expense"
      return "Expense at #{item.entity.merchant_name}"
    end
  end

  def entity_type(item)
    item.entity_type
  end

  def po_number(item)
    if item.entity.is_a?(PurchaseOrderItem)
      return item.entity.purchase_order.po_number
    end
    ""
  end

  def invoice_number(item)
    if item.entity.is_a?(InvoiceLineItem)
      return item.entity.parent.invoice_number
    end
    ""
  end

  def payment_id(item)
    if item.entity.is_a?(Payment)
      return item.entity&.id
    end
    ""
  end

  def expense_id(item)
    if item.entity.is_a?(Expense)
      return item.entity&.id
    end
    ""
  end

  def department(item)
    if item.entity&.is_a?(PurchaseOrderItem)
      return item.entity.department&.name
    elsif item.entity&.is_a?(InvoiceLineItem)
      return item.entity.department&.name
    elsif item.entity&.is_a?(Expense)
      return item.entity.report.department&.name
    elsif item.entity.is_a?(Payment)
      return item.entity.department&.name
    end
    ""
  end

  def cost_center(item)
    if item.entity&.is_a?(PurchaseOrderItem)
      return item.entity.cost_center&.name
    elsif item.entity&.is_a?(InvoiceLineItem)
      return item.entity.cost_center&.name
    elsif item.entity&.is_a?(Expense)
      return item.entity.report.cost_center&.name
    elsif item.entity.is_a?(Payment)
      return item.entity.cost_center&.name
    end
    ""
  end

  def location(item)
    if item.entity&.is_a?(PurchaseOrderItem)
      return item.entity.purchase_order.location&.name
    elsif item.entity&.is_a?(InvoiceLineItem)
      return item.entity.parent.location&.name
    elsif item.entity&.is_a?(Expense)
      ""
    elsif item.entity.is_a?(Payment)
      return item.entity.location&.name
    end
    ""
  end


  def category(item)
    if item.entity.is_a?(PurchaseOrderItem)
      return item.entity.category&.name || item.entity.inventory_line_item&.category&.name
    elsif item.entity.is_a?(InvoiceLineItem)
      return item.entity.category&.name || item.entity.inventory_line_item&.category&.name
    elsif item.is_a?(Payment)
      # limit the below to only include the categories that this budget applies to
      case item.parent_type
      when "Invoice"
        categories = Category.with_id(item.entity&.parent&.items&.pluck(:category_id).compact)
        return categories.pluck(:name).to_sentence
      when "BeneficiaryPayment"
        return item.entity.parent&.category&.name
      when "PurchaseOrder"
        categories = Category.with_id(item.entity&.parent&.items&.pluck(:category_id).compact)
        return categories.pluck(:name).to_sentence
      else
        return ""
      end
    end
    ""
  end

  def pending_amount(item)
    # the below needs to be worked on because the amounts will depend on each bucket
    if item.entity.is_a?(PurchaseOrderItem)
      return item.entity.total_amount&.value
    elsif item.entity.is_a?(InvoiceLineItem)
      return item.entity.net_amount&.value
    elsif item.entity.is_a?(Payment)
      return item.entity.amount&.value
    elsif item.entity.is_a?(Expense)
      return item.entity.amount&.value
    end
    ""
  end

  def committed_amount(item)
    # the below needs to be worked on because the amounts will depend on each bucket
    if item.entity.is_a?(PurchaseOrderItem)
      return item.entity.total_amount&.value
    elsif item.entity.is_a?(InvoiceLineItem)
      return item.entity.net_amount&.value
    elsif item.entity.is_a?(Payment)
      return item.entity.amount&.value
    elsif item.entity.is_a?(Expense)
      return item.entity.amount&.value
    end
    ""
  end

  def payment_processing_amount(item)
    # the below needs to be worked on because the amounts will depend on each bucket
    if item.entity.is_a?(PurchaseOrderItem)
      return item.entity.total_amount&.value
    elsif item.entity.is_a?(InvoiceLineItem)
      return item.entity.net_amount&.value
    elsif item.entity.is_a?(Payment)
      return item.entity.amount&.value
    elsif item.entity.is_a?(Expense)
      return item.entity.amount&.value
    end
    ""
  end


  def paid_amount(item)
    # the below needs to be worked on because the amounts will depend on each bucket
    if item.entity.is_a?(PurchaseOrderItem)
      return item.entity.total_amount&.value
    elsif item.entity.is_a?(InvoiceLineItem)
      return item.entity.net_amount&.value
    elsif item.entity.is_a?(Payment)
      return item.entity.amount&.value
    elsif item.entity.is_a?(Expense)
      return item.entity.amount&.value
    end
    ""
  end

  def merchant(item)
    if item.entity.is_a?(Expense)
      return item.entity.merchant_name
    end
    ""
  end

  def vendor(item)
    if item.entity.is_a?(PurchaseOrderItem)
      return item.entity.purchase_order.vendor&.name
    elsif item.entity.is_a?(InvoiceLineItem)
      return item.entity.parent.vendor&.name
    elsif item.entity.is_a?(Payment)
      return item.entity.receiving_user&.name
    end
    ""
  end

  def created_at(item)
    item.entity.created_at.strftime("%d %B, %Y")
  end

  def submitted_at(item)
    if item.entity.is_a?(PurchaseOrderItem)
      return item.entity.purchase_order.submitted_at&.strftime("%d %B, %Y")
    elsif item.entity.is_a?(InvoiceLineItem)
      return item.entity.parent.submitted_at&.strftime("%d %B, %Y")
    elsif item.entity.is_a?(Payment)
      return item.entity.bank_payment_request.submitted_at&.strftime("%d %B, %Y")
    elsif item.entity.is_a?(Expense)
      return item.entity.report.submitted_at&.strftime("%d %B, %Y")
    end
  end

  def created_by(item)
    if item.entity.is_a?(PurchaseOrderItem)
      return item.entity.purchase_order.user&.name
    elsif item.entity.is_a?(InvoiceLineItem)
      return item.entity.parent.created_by&.name
    elsif item.entity.is_a?(Payment)
      return item.entity.initiating_user&.name
    elsif item.entity.is_a?(Expense)
      return item.entity.user&.name
    end
    ""
  end
end