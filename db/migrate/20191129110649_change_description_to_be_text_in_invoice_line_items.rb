class ChangeDescriptionToBeTextInInvoiceLineItems < ActiveRecord::Migration[5.2]
  def change
    change_column :invoice_line_items, :description, :text
  end
end
