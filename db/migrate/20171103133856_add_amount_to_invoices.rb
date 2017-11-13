class AddAmountToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :amount_id, :integer, references: "Amount", index: true, foreign_key: true
  end
end
