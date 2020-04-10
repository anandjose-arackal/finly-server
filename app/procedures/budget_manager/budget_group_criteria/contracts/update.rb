class BudgetManager::BudgetGroupCriteria::Contracts::Update < Reform::Form


  property :name

  collection :budget_group_criteria_mappings, populator: :budget_group_criteria_mappings! do
    property :budget_group_criterium_id, presence: true
    property :budgetable_id, presence: true
    property :budgetable_type, presence: true
  end

  def budget_group_criteria_mappings!(collection:, fragment:, index:, **)
    budget_group_criteria_mappings.insert(index, BudgetGroupCriteriaMapping.new)
  end
end