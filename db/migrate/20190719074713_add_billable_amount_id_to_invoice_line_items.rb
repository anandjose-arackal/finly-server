class AddBillableAmountIdToInvoiceLineItems < ActiveRecord::Migration[5.2]
  def change
    add_column :invoice_line_items, :billable_amount_id, :integer, references: 'Amount', foreign_key: true
  end
end
