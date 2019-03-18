class AddFieldsToIciciBankCompanyAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :icici_bank_company_accounts, :company_id, :integer, references: "Company", foreign_key: true, index: true
    add_column :icici_bank_company_accounts, :balance_id, :integer, references: "Amount", foreign_key: true, index: true
  end
end
