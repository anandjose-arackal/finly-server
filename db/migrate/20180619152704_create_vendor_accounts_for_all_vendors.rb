class CreateVendorAccountsForAllVendors < ActiveRecord::Migration[4.2]
  def change
    YesBankVendor.all.each do |vendor|
      if vendor.vendor_account.blank?
        vendor.build_vendor_account(balance_attributes: {value: 0, currency_id: 1}).save
      end
    end
  end
end