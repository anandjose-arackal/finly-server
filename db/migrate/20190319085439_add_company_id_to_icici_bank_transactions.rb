class AddCompanyIdToIciciBankTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :icici_bank_transactions, :company_id, :integer, references: "Company", foreign_key: true, index: true
  end
end