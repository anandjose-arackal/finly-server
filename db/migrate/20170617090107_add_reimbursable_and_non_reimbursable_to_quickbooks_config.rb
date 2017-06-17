class AddReimbursableAndNonReimbursableToQuickbooksConfig < ActiveRecord::Migration
  def change
    add_column :quickbooks_configurations, :reimbursable_account_id, :integer, references: 'QuickbooksPaymentType', index: true, foreign_key: true
    add_column :quickbooks_configurations, :non_reimbursable_account_id, :integer, references: 'QuickbooksPaymentType', index: true, foreign_key: true
  end
end
