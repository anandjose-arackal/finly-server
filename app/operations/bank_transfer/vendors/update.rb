class BankTransfer::Vendors::Update < BankTransfer::Vendors::Base

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

    # checking for attachments and adding the id
    if self.vendor_parameters&.dig(:vendor_attachment_attributes)
      # only if the actual attached file is present, do you even make it save
      if self.vendor_parameters[:vendor_attachment_attributes].first[:attached_file].present?
        if self.vendor.vendor_attachments.present?
          self.vendor_parameters[:vendor_attachment_attributes].first[:id] = self.vendor.vendor_attachments.first&.id
        end
        self.vendor_parameters[:vendor_attachment_attributes].first.delete(:remove_file)
      elsif self.payment_params[:vendor_attachment_attributes].first[:remove_file] == '1'
        self.vendor_parameters[:vendor_attachment_attributes].first[:_destroy] = true
        self.vendor_parameters[:vendor_attachment_attributes].first[:id] = self.vendor.vendor_attachments.first&.id
        self.vendor_parameters[:vendor_attachment_attributes].first.delete(:remove_file)
      else
        if self.payment.invoice&.invoice_attachments.present?
          self.vendor_parameters[:vendor_attachment_attributes].first.delete(:remove_file)
        else
          self.vendor_parameters.delete(:vendor_attachment_attributes)
        end
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