class AddRoundoffAndBalanceDueToInvoice < ActiveRecord::Migration[4.2]
  def change
    add_column :invoices, :roundoff_amount_id, :integer, references: "Amount", foreign_key: true, index: true
    add_column :invoices, :balance_due_id, :integer, references: "Amount", index: true, foreign_key: true
  end
end
