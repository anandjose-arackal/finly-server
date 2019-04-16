class VendorMigrationPostOp < ActiveRecord::Migration[5.2]
  def change
    # Authorized Vendors
    vendors = YesBankVendor.where.not(authorized: nil)

    # Migrating TDS to Vendor TDS Rates. OKAY
    p "Migrating TDS Rates"
    vendors.where.not(tds_rates_list_id: nil).each do |vendor|
      vendor.vendor_tds_rates.build(tds_rates_list_id: vendor.tds_rates_list_id).save
    end

    # Set status to auto approved for all vendors
    p "Setting Vendor Status id"
    vendors.where(status_id: nil).update_all(status_id: VendorStatus.id_for(:auto_approved))

    # MSME Registered Number for OLX
    p "Migrating OLX Vendors' Custom Fields"
    vendors.where(status_id: nil).update_all(status_id: VendorStatus.id_for(:auto_approved))
    olx_vendor_ids = vendors.where(company_id: 118).pluck(:id)
    vendor_custom_fields = CustomField.where(parent_type: 'YesBankVendor', parent_id: olx_vendor_ids)
    vendor_custom_fields.where.not(value_id: nil).where(field_key: "msme_number").each do |cf|
      cf.parent.update(msme_registered: true, msme_registration_number: cf.value.value)
    end
  end
end
