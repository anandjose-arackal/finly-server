class AddAccountNumberToYesBankAccount < ActiveRecord::Migration
  def change
    add_column :yes_bank_company_accounts, :account_number, :string
    add_column :yes_bank_company_accounts, :customer_id, :string
  end
end
