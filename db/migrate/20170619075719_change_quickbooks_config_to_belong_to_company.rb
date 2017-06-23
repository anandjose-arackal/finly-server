class ChangeQuickbooksConfigToBelongToCompany < ActiveRecord::Migration
  def change
    add_column :quickbooks_configurations, :company_id, :integer, references: 'Company', foreign_key: true, index: true
  end
end
