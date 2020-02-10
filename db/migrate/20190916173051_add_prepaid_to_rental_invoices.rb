class AddPrepaidToRentalInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :rental_invoices, :prepaid, :boolean
  end
end
