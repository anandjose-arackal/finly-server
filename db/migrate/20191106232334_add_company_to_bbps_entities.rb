class AddCompanyToBbpsEntities < ActiveRecord::Migration[5.2]
  def change
    add_column :bbps_biller_subscriptions, :company_id, :integer, references: 'Company', index: true, foreign_key: true
    add_column :bbps_bills, :company_id, :integer, references: 'Company', index: true, foreign_key: true
  end
end
