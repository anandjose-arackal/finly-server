class AddCompanyIdToBankAccounts < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :company_id, :integer
  end
end
