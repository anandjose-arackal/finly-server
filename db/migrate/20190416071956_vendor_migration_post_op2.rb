class VendorMigrationPostOp2 < ActiveRecord::Migration[5.2]
  def change
    # Authorized Vendors
    vendors = YesBankVendor.where.not(authorized: nil)

    # Moving gstin to gstin
    p "Migrating GST to GSTIN"
    total_vendors = vendors.where.not(gst: nil).where("length(gst) = 15").count
    vendors.where.not(gst: nil).where("length(gst) = 15").each_with_index do |vendor, index|
      next if vendor.gstin_locations.count > 0
      # vendor.gst

      user = User.find_by id: vendor.created_by_id

      unless user.present?
        user = vendor.company.users.only_admins.first

        unless user.present?
          user = User.find_by email: 'kumarabinash@finly.io'
        end
      end

      # Get gstin details from api
      p "#{index + 1} / #{total_vendors} - #{vendor.gst}"
      op = Vendors::Support::ValidateGstin.(user, {gstin_location: {gstin: vendor.gst, business_name: ""}})

      if op.success? && op.gstin_master.present?
        # Save gstin details
        gstin = vendor.gstin_locations.new({
          gstin_id: op.gstin_master.id,
          gstin: op.gstin_master.gstin,
          poc_name: op.gstin_master.legal_name_of_business,
          poc_email: vendor.email,
          poc_mobile_number: vendor.mobile_number
        })

        # Save gstin
        gstin.save

        # Update vendor if business name is blank
        unless vendor.business_name.present?
          vendor.update_attribute('business_name', op.gstin_master.legal_name_of_business)
        end
      end
    end

    # Moving name to business name
    p "Migrating Name to Business Name"
    vendors.where(business_name: nil).each do |vendor|
      vendor.update(business_name: vendor.name)
    end
  end
end
