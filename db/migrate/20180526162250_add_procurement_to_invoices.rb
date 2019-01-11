class AddProcurementToInvoices < ActiveRecord::Migration[4.2]
  def change
    add_column :invoices, :procurement_id, :integer, references: "Procurement", foreign_key: true, index: true
  end
end
