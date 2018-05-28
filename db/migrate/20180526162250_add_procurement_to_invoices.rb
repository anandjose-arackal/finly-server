class AddProcurementToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :procurement_id, :integer, references: "Procurement", foreign_key: true, index: true
  end
end
