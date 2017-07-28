class AddBalanceToYesAndItzCompanyAccount < ActiveRecord::Migration
  def change
    add_column :yes_bank_company_accounts, :balance_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :itz_cash_company_accounts, :balance_id, :integer, references: "Amount", foreign_key: true, index: true
  end
end
