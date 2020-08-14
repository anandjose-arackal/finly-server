class Personalizer::Adapters::Company220::Procurements220::PurchaseOrders220::Validate < Personalizer::Adapters::Base
  attr_accessor :purchase_order, :budgets

  def init
    self.purchase_order = op_instance.purchase_order

    op = BudgetManager::BudgetsCalculator::ApplicableBudgets.({document: self.purchase_order, current_user: User.first})
    if op.success?
      self.budgets = op["result"][:budgets] rescue []
    end
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
    end
  end

  def process
    sleep 0.5   # NOTE: There is a race condition between updating accessing total_consumed_amount value
    budgets.each do |budget|
      budget_criteria = budget.budget_group_criterium
      budget_amount = budget.budget_consumption&.budget_amount&.value
      budget_spent_amount = budget.budget_consumption&.total_consumed_amount&.value

      spent_amount = budget_spent_amount

      if spent_amount > budget_amount or budget_amount == 0
        add_message :error, "Purchase Order Amount exceeding Budget - #{budget_criteria.name}"
      end
    end

    if messages[:error].present?
      add_message :error, 'Please contact finance to allocate more budget'
    end
  end

end