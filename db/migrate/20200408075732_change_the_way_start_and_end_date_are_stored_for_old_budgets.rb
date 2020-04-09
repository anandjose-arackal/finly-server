class ChangeTheWayStartAndEndDateAreStoredForOldBudgets < ActiveRecord::Migration[5.2]
  def change
    BudgetGroup.all.each do |budget_group|
      budget_group.update(start_date: budget_group.start_date.end_of_day)
      budget_group.update(end_date: budget_group.start_date.beginning_of_day)
    end
  end
end
