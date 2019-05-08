class AddBusinessNameForAllVendors < ActiveRecord::Migration[5.2]
  def change
    spurious_vendors = YesBankVendor.where(business_name: nil)
    spurious_vendors.each do |vendor|
      if vendor.business_name.blank?
        vendor.update_column(:business_name, vendor.name)
      end
    end
  end
end
