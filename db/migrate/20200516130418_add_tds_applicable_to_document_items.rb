class AddTdsApplicableToDocumentItems < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_order_items, :tds_applicable, :boolean, default: false
    add_column :invoice_line_items, :tds_applicable, :boolean, default: false

    PurchaseOrderItem.all.each do |purchase_order_item|
      if purchase_order_item.inventory_line_item_id.present?
        purchase_order_item.update_column(:tds_applicable, purchase_order_item.inventory_line_item.tds_applicable )
      end
    end

    InvoiceLineItem.all.each do |invoice_line_item|
      if invoice_line_item.inventory_line_item_id.present?
        invoice_line_item.update_column(:tds_applicable, invoice_line_item.inventory_line_item.tds_applicable )
      end
    end
  end
end
