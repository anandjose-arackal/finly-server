class BudgetsCalculator::Calculate::ExpenseBudgetsProcessor < BudgetsCalculator::Calculate::BudgetsProcessor

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
        date: expense.report.submitted_at&.to_date,
        department_id: expense.report.department_id,
        sub_department_id: expense.report.sub_department_id,
        amount_attributes: {
            value: expense.amount&.value,
            currency_id: expense.amount&.currency_id
        }
    }
    # todo - add location and department once they are implemented for reports
    # now calling super so that the budget trail is saved
    super()
  end

  # this is a safe delete, i.e. if the this payment doesn't exist in the budget_trail table, it gracefully exits
  def destroy_trail(expense)
    budget_trail = BudgetTrail.find_by(entity_type: "Expense", entity_id: expense.id)
    budget_trail&.destroy
  end
end