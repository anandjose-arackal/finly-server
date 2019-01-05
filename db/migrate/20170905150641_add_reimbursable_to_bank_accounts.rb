class AddReimbursableToBankAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :bank_accounts, :reimbursable, :boolean
  end
end
