class AddDeliveryLocationIdToGeneralInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :general_invoices, :delivery_location_id, :integer
  end
end
