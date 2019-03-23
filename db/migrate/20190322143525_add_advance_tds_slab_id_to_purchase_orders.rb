class AddAdvanceTdsSlabIdToPurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :advance_tds_slab_id, :integer, references: 'TdsRatesList', foreign_key: true
  end
end
