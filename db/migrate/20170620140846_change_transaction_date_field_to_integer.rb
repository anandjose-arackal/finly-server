class ChangeTransactionDateFieldToInteger < ActiveRecord::Migration
  def change
    change_column :quickbooks_configurations, :transaction_date_field, :integer
  end
end
