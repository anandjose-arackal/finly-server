class AddTaxableAmountIdToPurchaseOrderItems < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_order_items, :taxable_amount_id, :integer, references: 'Amount', foreign_key: true
    add_index :purchase_order_items, :taxable_amount_id
  end
end
