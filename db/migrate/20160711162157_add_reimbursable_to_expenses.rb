class AddReimbursableToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :reimbursable, :boolean, default: false, null: false
  end
end
