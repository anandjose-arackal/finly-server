class AddVendorPocToPurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    # add_column :purchase_orders, :vendor_poc_name, :string
    # add_column :purchase_orders, :vendor_poc_email, :string
    # add_column :purchase_orders, :vendor_poc_mobile_number, :string

    PurchaseOrder.non_deleted.each do |po|
      gstin_location = po.gstin_location
      if gstin_location.present?
        po.update_columns({vendor_poc_name: gstin_location.poc_name, vendor_poc_email: gstin_location.poc_email, vendor_poc_mobile_number: gstin_location.poc_mobile_number})
      end
    end
  end
end
