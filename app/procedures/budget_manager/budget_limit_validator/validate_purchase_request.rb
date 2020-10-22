class BudgetManager::BudgetLimitValidator::ValidatePurchaseRequest < BaseOperation
  attr_accessor :purchase_request, :budgets
  
  def init
    self.purchase_request = params[:purchase_request]
    
    op = BudgetManager::BudgetsCalculator::ApplicableBudgets.({document: self.purchase_request, current_user: User.first})
    if op.success?
      self.budgets = op["result"][:budgets] rescue []
    end
  end

  def validate
  end

  def process
    # adding logic for checking if budget is being exceeded

    self.budgets.each do |budget|
      budget_criteria = budget.budget_group_criterium
      budget_amount = budget.budget_consumption&.budget_amount&.value
      budget_spent_amount = budget.budget_consumption&.total_consumed_amount&.value

      spent_amount = budget_spent_amount

      if budget.purchase_request
        op = BudgetManager::BudgetsCalculator::Calculate::BudgetsComputer.({budget: budget, current_user: User.first, calculate_buckets: false, calculate_trail_items: true})

        if budget.calculated_before_tax_amount
          spent_amount += op['result'][:budget_trails].where(entity: purchase_request).map(&:amount_before_tax).map(&:value).sum
        else
          spent_amount += op['result'][:budget_trails].where(entity: purchase_request).map(&:amount_after_tax).map(&:value).sum
        end
      end

      if spent_amount > budget_amount or budget_amount == 0
        budget_exceeded = false
        add_message :error,  "Purchase Request Amount exceeding Budget - #{budget_criteria.name}"
      end
    end

    # adding overall message to the user
    if budget_exceeded
      add_message :error, 'Please contact finance to allocate more budget'
    end
  end
end
