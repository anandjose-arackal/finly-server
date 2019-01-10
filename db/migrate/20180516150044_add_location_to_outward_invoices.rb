class AddLocationToOutwardInvoices < ActiveRecord::Migration[4.2]
  def change
    add_reference :outward_invoices, :location, index: true, foreign_key: true
    remove_reference :outward_invoices, :company_branch, index: true, foreign_key: true
  end
end
