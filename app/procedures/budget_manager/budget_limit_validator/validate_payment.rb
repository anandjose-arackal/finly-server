class BudgetManager::BudgetLimitValidator::ValidatePayment < BaseOperation
  attr_accessor :payment, :budgets
  
  def init
    self.payment = params[:payment]
    self.document = payment.bank_payment_request || payment.payment_order
    if document.blank?
      add_message :error,  "Document not found"
      return
    end
    op = BudgetManager::BudgetsCalculator::ApplicableBudgets.({document: self.document, current_user: User.first})
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

      if budget.payment
        op = BudgetManager::BudgetsCalculator::Calculate::BudgetsComputer.({budget: budget, current_user: User.first, calculate_buckets: false, calculate_trail_items: true})

        if budget.calculated_before_tax_amount
          spent_amount += op['result'][:budget_trails].where(entity: payment).map(&:amount_before_tax).map(&:value).sum
        else
          spent_amount += op['result'][:budget_trails].where(entity: payment).map(&:amount_after_tax).map(&:value).sum
        end
      end

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
