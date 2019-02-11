class ChangeDefaultFlagForReimbursableInExpenses < ActiveRecord::Migration[4.2]
  def change
    change_column_default :expenses, :reimbursable, nil
  end
end
