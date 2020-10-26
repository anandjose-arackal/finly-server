class BudgetManager::BudgetLimitValidator::ValidateInvoice < BaseOperation
  attr_accessor :invoice, :purchase_order, :procurement, :budgets
  
  def init
    self.invoice = params[:invoice]
    self.procurement = self.invoice.procurement
    self.purchase_order = self.procurement&.purchase_order
    op = BudgetManager::BudgetsCalculator::ApplicableBudgets.({document: self.invoice, current_user: User.first})
    if op.success?
      self.budgets = op["result"][:budgets] rescue []
    end
  end

  def validate
    unless self.procurement.present?
      add_message :error, 'Procurement not found'
    end
  end

  def process
    # adding logic for checking if budget is being exceeded
    if self.invoice.procurement&.non_po_procurement?
      budget_exceeded = false
      self.budgets.each do |budget|
        budget_criteria = budget.budget_group_criterium
        budget_amount = budget.budget_consumption&.budget_amount&.value.to_f
        budget_spent_amount = budget.budget_consumption&.total_consumed_amount&.value.to_f

        spent_amount = budget_spent_amount

        if budget.purchase_order || budget.invoice
          op = BudgetManager::BudgetsCalculator::Calculate::BudgetsComputer.({budget: budget, current_user: User.first, calculate_buckets: false, calculate_trail_items: true})

          if budget.calculated_before_tax_amount
            spent_amount += op['result'][:budget_trails].where(entity: invoice.items).sum('billed_amount_before_tax_value')
          else
            spent_amount += op['result'][:budget_trails].where(entity: invoice.items).sum('billed_amount_after_tax_value')
          end
        end

        Rails.logger.fatal "**************************************************************************************************"
        Rails.logger.fatal "spent_amount --- #{spent_amount}"
        Rails.logger.fatal "budget_amount --- #{budget_amount}"
        Rails.logger.fatal "spent_amount > budget_amount or budget_amount == 0 --- #{spent_amount > budget_amount or budget_amount == 0}"
         
        if spent_amount > budget_amount or budget_amount == 0
          budget_exceeded = false
          add_message :error,  "Invoice Amount exceeding Budget - #{budget_criteria.name}"
        end
        Rails.logger.fatal "**************************************************************************************************"
      end

      # adding overall message to the user
      if budget_exceeded
        add_message :error, 'Please contact finance to allocate more budget'
      end
    end
  end
end
