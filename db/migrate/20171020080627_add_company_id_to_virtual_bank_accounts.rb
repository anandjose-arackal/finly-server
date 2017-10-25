class AddCompanyIdToVirtualBankAccounts < ActiveRecord::Migration
  def change
    add_column :virtual_bank_accounts, :company_id, :integer, references: "Company", foreign_key: true, index: true
    VirtualAccountPurpose.seed_data
  end
end
