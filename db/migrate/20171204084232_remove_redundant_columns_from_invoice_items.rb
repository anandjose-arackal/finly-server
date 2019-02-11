class RemoveRedundantColumnsFromInvoiceItems < ActiveRecord::Migration[4.2]
  def change
    remove_column :invoice_line_items, :tds, :decimal
    remove_column :invoice_line_items, :tds_amount_id, :integer
  end
end
