class BankTransfer::Vendors::Create < BankTransfer::Vendors::Base

  attr_accessor :vendor_parameters, :vendor

  def init
    super()
    self.vendor_parameters = vendor_attributes
  end

  def pre_process
    # setting the first account as default if none of them are marked as default
    # todo - temporary fix, will be taken in the front end later
    default = false
    self.vendor_parameters[:bank_accounts_attributes].each do |param|
      if [true].include?(StringUtils.to_bool param[:default_account])
        default = true
      end
    end
    unless default
      vendor_parameters[:bank_accounts_attributes].first[:default_account] = '1'
    end
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