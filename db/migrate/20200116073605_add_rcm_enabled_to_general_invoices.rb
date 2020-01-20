class AddRcmEnabledToGeneralInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :general_invoices, :rcm_enabled, :boolean
  end
end
