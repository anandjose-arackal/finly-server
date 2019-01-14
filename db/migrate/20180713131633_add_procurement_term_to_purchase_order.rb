class AddProcurementTermToPurchaseOrder < ActiveRecord::Migration[4.2]
  def change
    add_column :purchase_orders, :procurement_term_text, :text
  end
end
