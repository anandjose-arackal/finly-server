class AddTotalPayableToOutwardInvoices < ActiveRecord::Migration
  def change
    add_column :outward_invoices, :total_payable_id, :integer, references: "Amount", foreign_key: true, index: true
  end
end
