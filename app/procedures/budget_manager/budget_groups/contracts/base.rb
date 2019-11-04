class BudgetManager::BudgetGroups::Contracts::Base < Reform::Form

  properties :name, :purchase_order, :payment, :expense, :purchase_request, :invoice
  property :period_id, validates: {presence: true}
  property :company, validates: {presence: true}

  collection :budget_group_criteria_mappings, populator: :budget_group_criteria_mappings! do
    property :budget_group_id, presence: true
    property :budgetable_id, presence: true
    property :budgetable_type, presence: true
  end

  def budget_group_criteria_mappings!(collection:, fragment:, index:, **)
    budget_group_criteria_mappings.insert(index, BudgetGroupCriteriaMapping.new)
  end

end