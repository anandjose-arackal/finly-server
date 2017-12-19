class BankTransfer::Vendors::Create < BankTransfer::Vendors::Base

  attr_accessor :vendor_parameters, :vendor

  def personalizer
    {
        validate: {
            after: Personalizer::Process.new([:vendors, :create], :validate, self)
        }
    }
  end

  def init
    super()
    self.vendor_parameters = vendor_attributes
  end

  def validate
    # checking if a particular bank account already exists, if it does, just mark that respective vendor
    # as authorized and add the bank account to their existing list
    self.vendor_parameters[:bank_accounts_attributes].each_with_index do |account_params, index|
      ba = current_company.bank_accounts.find_by(account_number: account_params[:account_number])
      if ba.present?
        self.vendor = ba.account_owner
        # removing this particular bank account from the list of bank accounts being created
        vendor_parameters[:bank_accounts_attributes].delete_at(index)
      end
    end
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
      if vendor_parameters[:bank_accounts_attributes]&.first.present?
        vendor_parameters[:bank_accounts_attributes]&.first[:default_account] = '1'
      end
    end

    # if the receipt is being uploaded, delete the 'remove_file' key
    if vendor_parameters&.dig(:vendor_attachments_attributes).present?
      vendor_parameters[:vendor_attachments_attributes].first&.delete(:remove_file)
    end
  end

  def process
    debugger
    if self.vendor.present? && vendor.is_a?(YesBankVendor)
      self.vendor_parameters[:bank_accounts_attributes].each do |account_params|
        bank_account = self.vendor.bank_accounts.build(account_params)
        unless bank_account.save
          add_message :error, bank_account.errors.full_messages
        end
      end
      # also mark the vendor as authorized now
      self.vendor.update(authorized: true)
    else
      self.vendor = company.yes_bank_vendors.build(vendor_parameters)
      debugger
      unless self.vendor.save
        debugger
        add_message :error, vendor.errors.full_messages
      end
    end
  end

  def post_process
    add_message :success, "Vendor added"
  end

end