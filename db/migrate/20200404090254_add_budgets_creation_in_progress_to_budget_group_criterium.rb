class AddBudgetsCreationInProgressToBudgetGroupCriterium < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_group_criteria, :budget_creation_in_progress, :boolean, default: false
  end
end
