class ChangeDefaultFlagForReimbursableInExpenses < ActiveRecord::Migration
  def change
    change_column_default :expenses, :reimbursable, nil
  end
end
