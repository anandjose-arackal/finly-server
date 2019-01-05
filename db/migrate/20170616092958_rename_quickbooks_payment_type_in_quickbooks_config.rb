class RenameQuickbooksPaymentTypeInQuickbooksConfig < ActiveRecord::Migration[4.2]
  def change
    rename_column :quickbooks_configurations, :quickbooks_payment_type, :default_quickbooks_payment_type
  end
end
