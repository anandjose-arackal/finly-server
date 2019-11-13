class AddFixedPeriodicTemplateToRentalInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :rental_invoices, :fixed_periodic_template, :boolean
  end
end
