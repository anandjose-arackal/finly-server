class BudgetManager::BudgetLimitValidator::ValidatePurchaseOrder < BudgetManager::BudgetLimitValidator::Base

  attr_accessor :purchase_order, :budgets
  
  def init
    self.purchase_order = params[:purchase_order]

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
    budgets.each do |budget|
      budget_criteria = budget.budget_group_criterium
      budget_amount = budget.budget_consumption&.budget_amount&.value
      budget_spent_amount = budget.budget_consumption&.total_consumed_amount&.value

      spent_amount = budget_spent_amount

      # since this budget check is done while submitting po, po status will be open and the amount wont be added to spend amount. So, we get the amount corresponding amount and add it and check.
      if budget.purchase_order
        op = BudgetManager::BudgetsCalculator::Calculate::BudgetsComputer.({budget: budget, current_user: User.first, calculate_buckets: false, calculate_trail_items: true})

        if budget.calculated_before_tax_amount
          spent_amount += op['result'][:budget_trails].where(entity: purchase_order.items).sum('remaining_amount_before_tax_value')
        else
          spent_amount += op['result'][:budget_trails].where(entity: purchase_order.items).sum('remaining_amount_after_tax_value')
        end
      end

      if spent_amount > budget_amount or budget_amount == 0
        add_message :error, "Purchase Order Amount exceeding Budget - #{budget_criteria.name}"
      end
    end

    if messages[:error].present?
      add_message :error, 'Please contact finance to allocate more budget'
    end
  end
end
