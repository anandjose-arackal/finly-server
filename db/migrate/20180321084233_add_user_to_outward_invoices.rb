class AddUserToOutwardInvoices < ActiveRecord::Migration
  def change
    add_reference :outward_invoices, :user, index: true, foreign_key: true
  end
end
