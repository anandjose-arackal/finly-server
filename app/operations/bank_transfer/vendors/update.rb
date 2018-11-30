class BankTransfer::Vendors::Update < BankTransfer::Vendors::Base

  attr_accessor :vendor, :vendor_parameters

  def personalizer
    {
        validate: {
            after: Personalizer::Process.new([:vendors, :update], :validate, self)
        }
    }
  end

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

    # checking for attachments and adding the id
    if self.vendor_parameters&.dig(:vendor_attachments_attributes)
      # only if the actual attached file is present, do you even make it save
      if self.vendor_parameters[:vendor_attachments_attributes].first[:attached_file].present?
        if self.vendor.vendor_attachments.present?
          self.vendor_parameters[:vendor_attachments_attributes].first[:id] = self.vendor.vendor_attachments.first&.id
        end
        self.vendor_parameters[:vendor_attachments_attributes].first.delete(:remove_file)
      elsif self.vendor_parameters[:vendor_attachments_attributes].first[:remove_file] == '1'
        self.vendor_parameters[:vendor_attachments_attributes].first[:_destroy] = true
        self.vendor_parameters[:vendor_attachments_attributes].first[:id] = self.vendor.vendor_attachments.first&.id
        self.vendor_parameters[:vendor_attachments_attributes].first.delete(:remove_file)
      else
        if self.vendor.vendor_attachments.present?
          self.vendor_parameters[:vendor_attachments_attributes].first.delete(:remove_file)
        else
          self.vendor_parameters.delete(:vendor_attachments_attributes)
        end
      end
    end
  end

  def process
    validate_custom_fields(false)
    return if has_errors?
    unless vendor.update(vendor_parameters)
      add_message :error, vendor.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Vendor updated"
  end
end