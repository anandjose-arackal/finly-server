class BankTransfer::VendorTypes::Update < BankTransfer::VendorTypes::Base
  attr_accessor :vendor_type_params, :vendor_type

  def init
    self.vendor_type = user.company.vendor_types.find_by id: params[:id]
    self.vendor_type_params = vendor_type_parameters
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
    self.vendor_type.assign_attributes(vendor_type_params)
    if self.vendor_type.valid?
      self.vendor_type.save
      add_message :success, 'Updated Vendor Type'
    else
      add_message :error, self.vendor_type.errors.full_messages
    end
  end
end