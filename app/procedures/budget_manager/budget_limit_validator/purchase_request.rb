class BudgetManager::BudgetLimitValidator::PurchaseRequest < BudgetManager::BudgetLimitValidator::Base

  attr_accessor :purchase_request

  def initialize!(options, **)
    self.purchase_request = options[:purchase_request]

    self.previous_budget_contributions = options[:previous_budget_contributions] || {}
    self.budget_contributions = {}

    self.ignore_unbudgetables = options[:ignore_unbudgetables] || false

    unless purchase_request.present?
      add_message(options, :error, :base, 'Purchase Request not found')
      return false
    end

    op = BudgetManager::BudgetsCalculator::ApplicableBudgets.({document: self.purchase_request, current_user: User.first})
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

      if budget.purchase_request
        op = BudgetManager::BudgetsCalculator::Calculate::BudgetsComputer.({budget: budget, current_user: User.first, calculate_buckets: false, calculate_trail_items: true})

        trails = op['result'][:budget_trails].where(entity: purchase_request.items)

        if self.ignore_unbudgetables
          trails = trails.without_entity_status_id(PurchaseRequestStatus.status_ids_for_unbudgetables)
        end

        if budget.calculated_before_tax_amount
          trails_amount = trails.map(&:amount_before_tax).map(&:value).sum
        else
          trails_amount = trails.map(&:amount_after_tax).map(&:value).sum
        end
        budget_contributions[budget.id] = trails_amount
        spent_amount += trails_amount
        spent_amount -= previous_budget_contributions[budget.id] || 0

        if spent_amount > budget_amount or budget_amount == 0
          add_message(options, :error, :base, "Purchase Request Amount exceeding Budget - #{budget_criteria.name}")
        end
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
