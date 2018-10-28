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

  end

  def invoice_number(item)

  end

  def payment_id(item)

  end

  def expense_id(item)

  end

  def department(item)

  end

  def cost_center(item)

  end

  def category(item)

  end

  def amount(item)

  end

  def merchant(item)

  end

  def vendor(item)

  end

  def created_at(item)

  end

  def created_by(item)

  end
end