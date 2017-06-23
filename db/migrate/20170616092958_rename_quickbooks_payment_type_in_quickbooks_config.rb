class RenameQuickbooksPaymentTypeInQuickbooksConfig < ActiveRecord::Migration
  def change
    rename_column :quickbooks_configurations, :quickbooks_payment_type, :default_quickbooks_payment_type
  end
end
