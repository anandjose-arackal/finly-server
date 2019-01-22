class AddReimbursableExpensesFlagToBudgetRule < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_rules, :include_reimbursable, :boolean, default: true
  end
end
