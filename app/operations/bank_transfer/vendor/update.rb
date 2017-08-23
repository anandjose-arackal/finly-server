class BankTransfer::Vendor::Update < BankTransfer::Vendor::Base

  attr_accessor :vendor, :vendor_parameters

  def init
    id = params[:id] || params[:yes_bank_vendor_id]
    self.vendor_parameters = vendor_attributes
    self.vendor = YesBankVendor.find_by(id: id)
  end

  def validate
    if vendor.blank?
      add_message :error, "Vendor not found"
    end
  end

  def pre_process
    # here if the account number being added already exists, update the particular record and
    # don't create a new account
    vendor_parameters[:bank_accounts_attributes]&.each_with_index do |bank_account, index|
      ba = BankAccount.find_by(account_number: bank_account[:account_number])
      if ba.present?
        vendor_parameters[:bank_accounts_attributes][index][:id] = ba.id
      end
    end
  end

  def process
    unless vendor.update(vendor_parameters)
      add_message :error, vendor.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Vendor updated"
  end
end