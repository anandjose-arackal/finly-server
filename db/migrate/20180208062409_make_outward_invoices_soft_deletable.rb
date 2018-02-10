class MakeOutwardInvoicesSoftDeletable < ActiveRecord::Migration
  def change
    add_column :outward_invoices, :is_deleted, :boolean
  end
end
