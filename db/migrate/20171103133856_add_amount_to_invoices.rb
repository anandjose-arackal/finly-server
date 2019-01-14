class AddAmountToInvoices < ActiveRecord::Migration[4.2]
  def change
    add_column :invoices, :amount_id, :integer, references: "Amount", index: true, foreign_key: true
  end
end
