class AddFieldsToCompanyTransaction < ActiveRecord::Migration
  def change
    add_column :company_transactions, :transaction_mode, :string
    add_column :company_transactions, :merchant_type_key, :string
  end
end
