class AddCommentToInvoiceLineItems < ActiveRecord::Migration[4.2]
  def change
    add_column :invoice_line_items, :comment, :string
    add_column :invoices, :location_id, :integer, references: 'BranchLocation', foreign_key: true, index: true
    add_column :invoices, :delivery_location_id, :integer, references: 'BranchLocation', foreign_key: true, index: true
  end
end
