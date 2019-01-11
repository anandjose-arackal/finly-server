class ReplaceReimbursableWithTdsValueInExpenses < ActiveRecord::Migration[4.2]
  def change
    rename_column :expenses, :reimbursable_amount_id, :tds_amount_id
  end
end
