class BankTransfer::VendorTypes::Destroy < BankTransfer::VendorTypes::Base
  attr_accessor :vendor_type

  def init
    vendor_type_id = params[:id] || params[:vendor_type_id]
    self.vendor_type = user.company.vendor_types.find_by id: vendor_type_id
  end

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def validate
    unless self.vendor_type.present?
      add_message :error, 'Vendor Type not found'
    end
  end

  def process
    unless self.vendor_type.destroy
      add_message :error, self.vendor_type.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Vendor Type deleted."
  end
end