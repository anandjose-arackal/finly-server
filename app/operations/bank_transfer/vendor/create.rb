class BankTransfer::Vendor::Create < BankTransfer::Vendor::Base

  attr_accessor :vendor_parameters, :vendor

  def init
    super()
    self.vendor_parameters = vendor_attributes
  end

  def pre_process

  end

  def process
    self.vendor = company.yes_bank_vendors.build(vendor_parameters)
    unless self.vendor.save
      add_message :error, vendor.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Vendor added"
  end

end