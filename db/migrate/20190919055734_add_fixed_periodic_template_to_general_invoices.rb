class AddFixedPeriodicTemplateToGeneralInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :general_invoices, :fixed_periodic_template, :boolean
  end
end
