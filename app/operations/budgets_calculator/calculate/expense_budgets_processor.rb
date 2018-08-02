class BudgetsCalculator::Calculate::ExpenseBudgetsProcessor < BudgetsCalculator::BudgetsProcessor

  def self.save_trail(expense)
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
        date: expense.date,
        amount_attributes: {
            value: expense.amount&.value,
            currency_id: expense.amount&.currency_id
        }
    }
    # todo - add location and department once they are implemented for reports
    # now calling super so that the budget trail is saved
    super()
  end

  def self.destroy_trail(expense)
    budget_trail = BudgetTrail.find_by(entity_type: "Expense", entity_id: expense.id)
    budget_trail&.destroy
  end
end