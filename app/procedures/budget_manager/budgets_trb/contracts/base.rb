class BudgetManager::BudgetsTrb::Contracts::Base < Reform::Form

  properties :name, :start_date, :end_date, :budget_group_id, validates: {presence: true}
  property :company_id
  property :ancestry
  property :budget_group_id
  property :budget_amount, populate_if_empty: Amount do
    property :value
    property :currency_id
  end

  validate :budget_group_exists

  def budget_group_exists
    budget_group = BudgetGroup.find_by(id: self.budget_group_id)
    if budget_group&.company_id != company_id
      errors.add(:budget_group_id, "Budget Group not found")
    end
  end

end