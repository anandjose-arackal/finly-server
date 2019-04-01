class AddGstinLocationToPurchaseOrder < ActiveRecord::Migration[5.2]
  def change
    add_reference :purchase_orders, :gstin_location, foreign_key: true, index: true
  end
end
