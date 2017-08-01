class AddCompanyAccountTypeToCompanyAccounts < ActiveRecord::Migration
  def change
    add_reference :company_accounts, :company_account_type, index: true, foreign_key: true
  end
end
