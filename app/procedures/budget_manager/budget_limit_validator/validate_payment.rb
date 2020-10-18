class BudgetManager::BudgetLimitValidator::ValidatePayment < BaseOperation
  attr_accessor :payment, :budgets
  
  def init
    self.payment = params[:payment]

    op = BudgetManager::BudgetsCalculator::ApplicableBudgets.({document: self.payment, current_user: User.first})
    if op.success?
      self.budgets = op["result"][:budgets] rescue []
    end
  end

  def validate
  end

  def process
    # adding logic for checking if budget is being exceeded
    budget_exceeded = false
    self.budgets.each do |budget|
      budget_criteria = budget.budget_group_criterium
      budget_amount = budget.budget_consumption&.budget_amount&.value
      budget_spent_amount = budget.budget_consumption&.total_consumed_amount&.value

      spent_amount = budget_spent_amount

      if spent_amount > budget_amount or budget_amount == 0
        budget_exceeded = false
        add_message :error,  "Payment Amount exceeding Budget - #{budget_criteria.name}"
      end
    end

    # adding overall message to the user
    if budget_exceeded
      add_message :error, 'Please contact finance to allocate more budget'
    end
  end
end
