class AddCreatedByUserToBudgetGroupCriteria < ActiveRecord::Migration[5.2]
  def change
    add_column :budget_group_criteria, :created_by_user_id, :integer, references: "User", foreign_key: true, index: true
  end
end
