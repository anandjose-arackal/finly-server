class Personalizer::Adapters::Company118::Procurements118::PurchaseOrders118::Validate < Personalizer::Adapters::Base
  attr_accessor :purchase_order, :budgets
  def init
    self.purchase_order = op_instance.purchase_order

    op = BudgetsCalculator::RelevantBudgets.(user, object: self.purchase_order)
    if op.success?
      self.budgets = op.budget_data
    end
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
    end
  end

  def process
    budgets.each do |budget|
      budget_amount = budget[:budget].budget_amount.value
      budget_spent_amount = budget[:spent_amount]

      spent_amount = budget_spent_amount

      if spent_amount > budget_amount
        add_message :error, "Purchase Order Amount exceeding Budget - #{budget[:budget].name}"
      end
    end

    if messages[:error].present?
      add_message :error, 'Please contact finance to allocate more budget'
    end
  end

end