class AddReimbursableExpensesFlagToBudgetRule < ActiveRecord::Migration
  def change
    add_column :budget_rules, :include_reimbursable, :boolean, default: true
  end
end
