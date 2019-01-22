class ChangeTransactionDateFieldToInteger < ActiveRecord::Migration[4.2]
  def change
    change_column :quickbooks_configurations, :transaction_date_field, :integer
  end
end
