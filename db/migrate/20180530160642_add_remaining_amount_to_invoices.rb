class AddRemainingAmountToInvoices < ActiveRecord::Migration[4.2]
  def change
    add_column :invoices, :remaining_amount_id, :integer, references: "Amount", foreign_key: true, index: true
  end
end