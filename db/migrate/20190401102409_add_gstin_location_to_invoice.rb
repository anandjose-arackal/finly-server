class AddGstinLocationToInvoice < ActiveRecord::Migration[5.2]
  def change
    add_reference :invoices, :gstin_location, foreign_key: true, index: true
  end
end
