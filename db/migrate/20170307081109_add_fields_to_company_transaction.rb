class AddFieldsToCompanyTransaction < ActiveRecord::Migration[4.2]
  def change
    add_column :company_transactions, :transaction_mode, :string
    add_column :company_transactions, :merchant_type_key, :string
  end
end
