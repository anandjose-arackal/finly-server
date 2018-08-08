class MoveBudgetsFromSingleParentToManyParents < ActiveRecord::Migration
  def change
    Budget.all.each do |budget|
      budgetable = budget.budgetable_type.constantize.find_by(id: budget.budgetable_id)
      BudgetEntityMapping.create(budgetable: budgetable, budget: budget)
    end
  end
end
