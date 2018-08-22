class BudgetsProcessor::Calculate::CostCenter < BudgetsProcessor::Calculate::Base
  attr_accessor :cost_center_id

  def init
    super
    self.cost_center_id = budget.budgetable_id
  end

  def process
    if items_requested
      invoices = Invoice.with_cost_center_id(self.cost_center_id)
      invoice_ids = invoices.pluck(:id)

      payments = Payment.budget_payments(budget.start_date, budget.end_date).with_invoice(invoice_ids).with_amount
      self.spent_amount += payments.sum(:value)
      self.budget_trail_items += payments
    else
      invoices = Invoice.with_cost_center_id(self.cost_center_id)
      invoice_ids = invoices.pluck(:id)

      payments = Payment.budget_payments(budget.start_date, budget.end_date).with_invoice(invoice_ids).with_amount
      self.spent_amount += payments.sum(:value)
    end
  end
end