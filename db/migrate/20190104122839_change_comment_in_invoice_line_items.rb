class ChangeCommentInInvoiceLineItems < ActiveRecord::Migration[4.2]
  def up
    change_column :invoice_line_items, :comment, :text
  end
  def down
    change_column :invoice_line_items, :comment, :string
  end
end
