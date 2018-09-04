class AddUserIdToBudgetTrails < ActiveRecord::Migration
  def change
    add_column :budget_trails, :user_id, :integer, references: "User", foreign_key: true, index: true
  end
end
