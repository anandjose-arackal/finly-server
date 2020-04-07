class ExportManager::Master::Budgets::UsageEntities < ExportManager::Builders::Spreadsheet

  attr_accessor :entities, :budget_trails, :amount_to_be_considered,
                :po_item_amount_to_be_considered, :invoice_item_amount_to_be_considered, :paid_amount_to_be_considered, :payment_processing_amount_to_be_considered

  description 'Budget Trails Export'
  configurable true
  system :fi
  screen ['budget_group_criteria.index']
  handle :budget_entities

  validate :input

  attribute :entity_name #, column_name: "Entity Name", optional: false
  attribute :entity_type
  attribute :pr_number
  attribute :po_number
  attribute :invoice_number
  attribute :payment_id
  attribute :expense_id
  attribute :category
  attribute :department
  attribute :cost_center
  attribute :location
  attribute :amount
  # attribute :pending_amount
  # attribute :committed_amount
  # attribute :payment_processing_amount
  # attribute :paid_amount
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
    if budget.calculated_before_tax_amount
      self.amount_to_be_considered = :amount_before_tax
    else
      self.amount_to_be_considered = :amount_after_tax
    end

    case amount_to_be_considered
    when :amount_after_tax
      self.po_item_amount_to_be_considered = "remaining_amount_after_tax_value"
      self.invoice_item_amount_to_be_considered = "billed_amount_after_tax_value"
      self.paid_amount_to_be_considered = "paid_amount_after_tax_value"
      self.payment_processing_amount_to_be_considered = "payment_processing_amount_after_tax_value"
    when :amount_before_tax
      self.po_item_amount_to_be_considered = "remaining_amount_before_tax_value"
      self.invoice_item_amount_to_be_considered = "billed_amount_before_tax_value"
      self.paid_amount_to_be_considered = "effective_paid_amount_before_tax_value"
      self.payment_processing_amount_to_be_considered = "payment_processing_amount_before_tax_value"
    end

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
    when "PurchaseRequestItem"
      return item.entity.item&.get_custom_description
    end
  end

  def entity_type(item)
    item.entity_type.underscore.humanize
  end

  def pr_number(item)
    if item.entity.is_a?(PurchaseRequestItem)
      return item.entity&.purchase_request&.order_number
    elsif item.entity.is_a?(PurchaseOrderItem)
      return item.entity&.purchase_request_item&.purchase_request&.order_number
    end
  end

  def po_number(item)
    if item.entity.is_a?(PurchaseOrderItem)
      return item.entity.purchase_order.po_number
    elsif item.entity.is_a?(InvoiceLineItem)
      return item.entity.purchase_order_item&.purchase_order&.po_number
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
    elsif item.entity.is_a?(PurchaseRequestItem)
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
    elsif item.entity.is_a?(PurchaseRequestItem)
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
    elsif item.entity.is_a?(PurchaseRequestItem)
      return item.entity.purchase_request.location&.name
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
    elsif item.entity.is_a?(PurchaseRequestItem)
      return item.entity.category&.name
    end
    ""
  end

  def amount(item)
    # the below needs to be worked on because the amounts will depend on each bucket
    if item.entity.is_a?(PurchaseOrderItem)
      return item.entity.total_amount&.value
    elsif item.entity.is_a?(InvoiceLineItem)
      return item.entity.net_amount&.value
    elsif item.entity.is_a?(Payment)
      return item.entity.amount&.value
    elsif item.entity.is_a?(Expense)
      return item.entity.amount&.value
    elsif item.entity.is_a?(PurchaseRequestItem)
      return item.entity.estimated_amount&.value
    end
    ""
  end

  # def pending_amount(item)
  #   # the below needs to be worked on because the amounts will depend on each bucket
  #   if item.entity.is_a?(PurchaseOrderItem)
  #     return item.entity.total_amount&.value if PurchaseOrderStatus.status_ids_for_pending_bucket.include?(item.entity_status_id)
  #     return 0
  #   elsif item.entity.is_a?(InvoiceLineItem)
  #     return 0
  #   elsif item.entity.is_a?(Payment)
  #     return 0
  #   elsif item.entity.is_a?(Expense)
  #     return item.entity.amount&.value if ReportStatus.ids_for_pending_bucket.include?(item.entity_status_id)
  #     return 0
  #   end
  #   ""
  # end
  #
  # def committed_amount(item)
  #   # the below needs to be worked on because the amounts will depend on each bucket
  #   if item.entity.is_a?(PurchaseOrderItem)
  #     return (item.send(self.po_item_amount_to_be_considered) - item.send(self.paid_amount_to_be_considered) - item.send(self.payment_processing_amount_to_be_considered)) if PurchaseOrderStatus.status_ids_for_committed_bucket.include?(item.entity_status_id)
  #     return 0
  #   elsif item.entity.is_a?(InvoiceLineItem)
  #     return (item.send(self.invoice_item_amount_to_be_considered) - item.send(self.paid_amount_to_be_considered) - item.send(self.payment_processing_amount_to_be_considered)) if InwardInvoiceStatus.ids_for_committed_bucket.include?(item.entity_status_id) or InwardInvoiceStatus.ids_for_pending_payment_bucket.include?(item.entity_status_id)
  #     return 0
  #   elsif item.entity.is_a?(Payment)
  #     return item.tds_value if PaymentStatus.all_except_failed.include?(item.entity_status_id)
  #   elsif item.entity.is_a?(Expense)
  #     return item.send(self.amount_to_be_considered)&.value.to_f if ReportStatus.ids_for_pending_payment_bucket.include?(item.entity_status_id)
  #   end
  #   ""
  # end
  #
  # def payment_processing_amount(item)
  #   # the below needs to be worked on because the amounts will depend on each bucket
  #   if item.entity.is_a?(PurchaseOrderItem)
  #     return item.send(self.payment_processing_amount_to_be_considered) if PurchaseOrderStatus.ids_for_payment_processing_bucket.include?(item.entity_status_id)
  #     return 0
  #   elsif item.entity.is_a?(InvoiceLineItem)
  #     return item..send(self.payment_processing_amount_to_be_considered) if InwardInvoiceStatus.ids_for_payment_processing_bucket.include?(item.entity_status_id)
  #     return 0
  #   elsif item.entity.is_a?(Payment)
  #     return item.send(self.amount_to_be_considered)&.value.to_f if PaymentStatus.ids_for_payment_processing_bucket.include?(item.entity_status_id)
  #     return 0
  #   elsif item.entity.is_a?(Expense)
  #     return 0
  #   end
  #   ""
  # end
  #
  #
  # def paid_amount(item)
  #   # the below needs to be worked on because the amounts will depend on each bucket
  #   if item.entity.is_a?(PurchaseOrderItem)
  #     return item.send(self.paid_amount_to_be_considered) if PurchaseOrderStatus.ids_for_payment_processing_bucket.include?(item.entity_status_id)
  #     return 0
  #   elsif item.entity.is_a?(InvoiceLineItem)
  #     return item..send(self.paid_amount_to_be_considered) if InwardInvoiceStatus.ids_for_payment_processing_bucket.include?(item.entity_status_id)
  #     return 0
  #   elsif item.entity.is_a?(Payment)
  #     return item.send(self.amount_to_be_considered)&.value.to_f if PaymentStatus.ids_for_paid_bucket.include?(item.entity_status_id)
  #     return 0
  #   elsif item.entity.is_a?(Expense)
  #     return item.send(self.amount_to_be_considered)&.value.to_f if ReportStatus.ids_for_paid_bucket.include?(item.entity_status_id)
  #     return 0
  #   end
  #   ""
  # end

  def merchant(item)
    if item.entity.is_a?(Expense)
      return item.entity.merchant_name
    end
    ""
  end

  def vendor(item)
    if item.entity.is_a?(PurchaseOrderItem)
      return item.entity.purchase_order.vendor&.name || item.entity.purchase_order.vendor&.business_name
    elsif item.entity.is_a?(InvoiceLineItem)
      return item.entity.parent.vendor&.name || item.entity.parent.vendor&.business_name
    elsif item.entity.is_a?(Payment)
      return item.entity.receiving_user&.name
    elsif item.entity.is_a?(PurchaseRequestItem)
      return item.entity.purchase_request.vendor&.name || item.entity.purchase_request.vendor&.business_name
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
    elsif item.entity.is_a?(PurchaseRequestItem)
      return item.entity.purchase_request.submitted_at&.strftime("%d %B, %Y")
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
    elsif item.entity.is_a?(PurchaseRequestItem)
      return item.entity.purchase_request.created&.name
    end
    ""
  end
end