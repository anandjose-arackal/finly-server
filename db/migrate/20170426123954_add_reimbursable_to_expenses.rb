class AddReimbursableToExpenses < ActiveRecord::Migration[4.2]
  def change
    add_column :expenses, :reimbursable, :boolean, default: true
  end
end
