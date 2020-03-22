class AddStartDateAndEndDateToBudgetGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_groups, :start_date, :datetime
    add_column :budget_groups, :end_date, :datetime
  end
end
