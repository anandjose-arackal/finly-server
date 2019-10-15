class ChangeColumnTypesInPurchaseOrderItemsAndInwardDocumentItems < ActiveRecord::Migration[5.2]
  def change
  	change_column :inward_document_items, :billable_amount, :decimal, precision: 20, scale: 5, default: 0.0
  	change_column :inward_document_items, :order_amount, :decimal, precision: 20, scale: 5, default: 0.0
  	change_column :inward_document_items, :previously_billed_amount, :decimal, precision: 20, scale: 5, default: 0.0

  	change_column :purchase_order_items, :sgst, :decimal, precision: 20, scale: 5, default: 0.0
  	change_column :purchase_order_items, :igst, :decimal, precision: 20, scale: 5, default: 0.0
  	change_column :purchase_order_items, :previously_billed_amount, :decimal, precision: 20, scale: 5, default: 0.0

  	change_column :invoice_line_items, :sgst, :decimal, precision: 20, scale: 5, default: 0.0
  	change_column :invoice_line_items, :cgst, :decimal, precision: 20, scale: 5, default: 0.0
  	change_column :invoice_line_items, :igst, :decimal, precision: 20, scale: 5, default: 0.0
  end
end
