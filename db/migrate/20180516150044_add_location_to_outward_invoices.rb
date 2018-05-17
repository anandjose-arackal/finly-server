class AddLocationToOutwardInvoices < ActiveRecord::Migration
  def change
    add_reference :outward_invoices, :location, index: true, foreign_key: true
    remove_reference :outward_invoices, :company_branch, index: true, foreign_key: true
  end
end
