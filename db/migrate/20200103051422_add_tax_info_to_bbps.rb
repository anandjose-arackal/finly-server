class AddTaxInfoToBbps < ActiveRecord::Migration[5.2]
  def change
    add_column :bbps_biller_subscriptions, :tax_rate_id, :integer, references: 'TaxRate', foreign_key: true, index: true
    add_column :bbps_biller_subscriptions, :category_id, :integer, references: 'Category', foreign_key: true, index: true
    add_column :bbps_biller_subscriptions, :hsn_sac, :string, index: true

    add_column :bbps_bills, :tax_rate_id, :integer, references: 'TaxRate', foreign_key: true, index: true
    add_column :bbps_bills, :hsn_sac, :string, index: true
  end
end
