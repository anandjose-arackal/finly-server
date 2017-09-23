class AddReimbursableToBankAccounts < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :reimbursable, :boolean
  end
end
