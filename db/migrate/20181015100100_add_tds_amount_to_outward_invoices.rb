class AddTdsAmountToOutwardInvoices < ActiveRecord::Migration
  def change
    add_column :outward_invoices, :tds_amount_id, :integer, references: "Amount", foreign_key: true, index: true
  end
end
