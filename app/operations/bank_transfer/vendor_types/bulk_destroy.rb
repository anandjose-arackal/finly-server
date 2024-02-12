class BankTransfer::VendorTypes::BulkDestroy < BankTransfer::VendorTypes::Base
  attr_accessor :vendor_types

  def init
    vendor_type_ids = params[:ids] || params[:vendor_type_ids]
    self.vendor_types = user.company.vendor_types.where id: vendor_type_ids
  end

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def validate
    unless self.vendor_types.present?
      add_message :error, 'Vendor Type not found'
    end
  end

  def process
    if self.vendor_types.destroy_all
      add_message :success, 'Successfully removed multiple Vendor Types'
    else
      add_message :error, "Could not remove multiple Vendor Types"
    end
  end
end