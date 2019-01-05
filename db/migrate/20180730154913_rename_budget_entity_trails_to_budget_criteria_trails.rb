class RenameBudgetEntityTrailsToBudgetCriteriaTrails < ActiveRecord::Migration[4.2]
  def change
    rename_table :budget_entity_mappings, :budget_criteria_mappings

    # moved this migration from MoveBudgetsFromSingleParentToManyParents to this because the table name is renamed here
    Budget.all.each do |budget|
      budgetable = budget.budgetable_type.constantize.find_by(id: budget.budgetable_id)
      BudgetCriteriaMapping.create(budgetable: budgetable, budget: budget)
    end
  end
end
