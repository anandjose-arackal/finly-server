class AddProcurementTermToPurchaseOrder < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :procurement_term_text, :text
  end
end
