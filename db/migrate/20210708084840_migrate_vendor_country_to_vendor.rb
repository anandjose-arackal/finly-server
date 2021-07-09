class MigrateVendorCountryToVendor < ActiveRecord::Migration[6.0]
  def change
    ActsAsTenant.without_tenant do
      YesBankVendor.where(vendor_country: 'India').update_all(vendor_country_id: Country.id_for('India') )
      international_vendor_ids = YesBankVendor.where.not(vendor_country: 'India').pluck(:id)
      Rails.logger.fatal "#{international_vendor_ids}"
    end 
  end
end
