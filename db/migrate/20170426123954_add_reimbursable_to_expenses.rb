class AddReimbursableToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :reimbursable, :boolean, default: true
  end
end
