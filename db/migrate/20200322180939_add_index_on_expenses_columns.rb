class AddIndexOnExpensesColumns < ActiveRecord::Migration[5.2]
  def change
    add_index :expenses, :reimbursable
    add_index :expenses, :tds_amount_id
    add_index :reports, [:policy_id, :report_status_id], name: :report_joined_index_plcy_status
    add_index :policies, :settlement_currency_id
  end
end
