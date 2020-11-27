class BudgetManager::BudgetLimitValidator::Invoice < BudgetManager::BudgetLimitValidator::Base

  attr_accessor :invoice, :procurement, :purchase_order
  
  def initialize!(options, **)
    self.invoice = options[:invoice]

    self.previous_budget_contributions = options[:previous_budget_contributions] || {}
    self.budget_contributions = {}

    self.ignore_unbudgetables = options[:ignore_unbudgetables] || false

    unless self.invoice.present?
      add_message(options, :error, :base, 'Invoice not found')
      return false
    end

    self.procurement = self.invoice.procurement

    unless self.procurement.present?
      add_message(options, :error, :base, 'Procurement not found')
      return false
    end

    self.purchase_order = self.procurement&.purchase_order

    op = BudgetManager::BudgetsCalculator::ApplicableBudgets.({document: self.invoice, current_user: User.first})
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
    if self.invoice.procurement&.non_po_procurement?
      self.budgets.each do |budget|
        budget_criteria = budget.budget_group_criterium
        budget_amount = budget.budget_consumption&.budget_amount&.value.to_f
        budget_spent_amount = budget.budget_consumption&.total_consumed_amount&.value.to_f

        spent_amount = budget_spent_amount

        if budget.purchase_order || budget.invoice
          op = BudgetManager::BudgetsCalculator::Calculate::BudgetsComputer.({budget: budget, current_user: User.first, calculate_buckets: false, calculate_trail_items: true})

          trails = op['result'][:budget_trails].where(entity: invoice.items)

          if self.ignore_unbudgetables
            trails = trails.without_entity_status_id(InwardInvoiceStatus.status_ids_for_unbudgetables)
          end

          if budget.calculated_before_tax_amount
            trails_amount = trails.sum('billed_amount_before_tax_value - cn_adjusted_amount_after_tax_value')
          else
            trails_amount = trails.sum('billed_amount_after_tax_value - cn_adjusted_amount_before_tax_value')
          end

          budget_contributions[budget.id] = trails_amount
          spent_amount += trails_amount
          spent_amount -= previous_budget_contributions[budget.id] || 0

          if spent_amount > budget_amount or budget_amount == 0
            add_message(options, :error, :base, "Invoice Amount exceeding Budget - #{budget_criteria.name}")
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
    end
    return true
  end
end
