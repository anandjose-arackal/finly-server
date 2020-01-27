class AddRcmEnabledToRentalInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :rental_invoices, :rcm_enabled, :boolean
  end
end
