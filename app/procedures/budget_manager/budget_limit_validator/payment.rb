class BudgetManager::BudgetLimitValidator::Payment < BudgetManager::BudgetLimitValidator::Base

  attr_accessor :payment, :document
  
  def initialize!(options, **)
    self.payment = options[:payment]
    self.document = payment.bank_payment_request || payment.payment_order
    if document.blank?
      add_message(options, :error, :base, "Document not found")
      return false
    end

    op = BudgetManager::BudgetsCalculator::ApplicableBudgets.({document: self.document, current_user: User.first})
    if op.success?
      self.budgets = op["result"][:budgets] rescue []
    end

    unless self.budgets.present?
      add_message(options, :error, :base, 'No budgets available')
      add_message(options, :error, :base, 'Please contact finance to allocate more budget')
      return false
    end

    return true
  end

  def process!(options, **)
    # adding logic for checking if budget is being exceeded
    self.budgets.each do |budget|
      budget_criteria = budget.budget_group_criterium
      budget_amount = budget.budget_consumption&.budget_amount&.value
      budget_spent_amount = budget.budget_consumption&.total_consumed_amount&.value

      spent_amount = budget_spent_amount

      if budget.payment
        op = BudgetManager::BudgetsCalculator::Calculate::BudgetsComputer.({budget: budget, current_user: User.first, calculate_buckets: false, calculate_trail_items: true})

        if budget.calculated_before_tax_amount
          trails_amount = op['result'][:budget_trails].where(entity: payment).map(&:amount_before_tax).map(&:value).sum
        else
          trails_amount = op['result'][:budget_trails].where(entity: payment).map(&:amount_after_tax).map(&:value).sum
        end

        budget_contributions[budget.id] = trails_amount
        spent_amount += trails_amount
        spent_amount -= previous_budget_contributions[budget.id] || 0
      end

      if spent_amount > budget_amount or budget_amount == 0
        add_message(options, :error, :base, "Payment Amount exceeding Budget - #{budget_criteria.name}")
      end
    end

    options["result"] = {
      budget_contributions: budget_contributions
    }

    if options['result.operation.errors'].present?
      add_message options, :error, :base, 'Please contact finance to allocate more budget'

      return false
    end

    return true
  end
end
