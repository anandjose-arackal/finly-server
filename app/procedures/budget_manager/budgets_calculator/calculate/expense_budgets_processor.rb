class BudgetManager::BudgetsCalculator::Calculate::ExpenseBudgetsProcessor < BudgetManager::BudgetsCalculator::Calculate::BudgetsProcessor

  attr_accessor :trail_hash

  def save_trail(expense)
    trail = BudgetTrail.find_by(entity_type: "Expense", entity_id: expense.id)
    if trail.present?
      trail_id = trail.id
    else
      trail_id = nil
    end
    self.trail_hash = {
        id: trail_id,
        entity: expense,
        category_id: expense.category_id,
        user_id: expense.user_id,
        cost_center_id: expense.report.cost_center_id,
        department_id: expense.report.department_id,
        location_id: expense.report.location_id,
        date: expense.date,
        entity_created_at: expense.created_at,
        entity_submitted_at: (expense.report.submitted_at || expense.created_at),
        entity_status_id: expense.report.report_status_id,
        reimbursable: expense.reimbursable,
        billed_amount_before_tax_value: expense.amount_before_tax,
        billed_amount_after_tax_value: expense.amount_after_tax,
        amount_attributes: {
            id: trail&.amount&.id,
            value: expense.amount&.value,
            currency_id: expense.amount&.currency_id
        },
        amount_before_tax_attributes: {
            id: trail&.amount_before_tax&.id,
            value: expense.amount_before_tax,
            currency_id: expense.amount&.currency_id
        },
        amount_after_tax_attributes: {
            id: trail&.amount_after_tax&.id,
            value: expense.amount_after_tax,
            currency_id: expense.amount&.currency_id
        }
    }
    # now calling super so that the budget trail is saved
    super()
  end

  # this is a safe delete, i.e. if the this payment doesn't exist in the budget_trail table, it gracefully exits
  def destroy_trail(expense)
    budget_trail = BudgetTrail.find_by(entity_type: "Expense", entity_id: expense.id)
    budget_trail&.destroy
  end
end