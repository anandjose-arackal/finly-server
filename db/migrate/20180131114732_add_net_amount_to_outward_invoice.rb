class AddNetAmountToOutwardInvoice < ActiveRecord::Migration[4.2]
  def change
    add_column :outward_invoices, :net_amount_id, :integer, references: "Amount", foreign_key: true, index: true
  end
end
