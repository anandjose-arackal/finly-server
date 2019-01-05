class AddCompanyIdToBankAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :bank_accounts, :company_id, :integer
  end
end
