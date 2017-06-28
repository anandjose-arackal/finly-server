class ChangePaymentTypeInQuickbooksConfiguration < ActiveRecord::Migration
  def change
    remove_foreign_key :quickbooks_configurations, column: :payment_type_id
    remove_column :quickbooks_configurations, :payment_type_id, :integer
    add_reference :quickbooks_configurations, :quickbooks_payment_type, index: true, foreign_key: true
  end
end
