class Vendors::Update < Vendors::Base

  attr_accessor :vendor, :vendor_parameters

  def personalizer
    {
        validate: {
            after: Personalizer::Process.new([:vendors, :update], :validate, self)
        }
    }
  end

  def init
    # id = params[:id] || params[:yes_bank_vendor_id] || params[:vendor_id]
    self.vendor_parameters = vendor_attributes

    # Remove policy id from vendor params if present, as updating a vendor doesn't go through approval again
    self.vendor_parameters.delete(:policy_id)
    self.vendor = Vendors::Show.(user, params).vendor rescue nil
  end

  def validate
    if vendor.blank?
      add_message :error, "Vendor not found"
      return
    end

    unless (user.is_vendor_manager? || user.vendor_payment_admin?) || (vendor.created_by_id == user.id && YesBankVendor.status_ids(:retracted, :draft, :rejected).include?(vendor.status_id)) || (vendor.get_reviewers.include?(user) && vendor.awaiting_approval?)
      add_message :error, "You do not have permission for this action"
    end

    # Remove tds from vendor params if tds_rates_list_id is blank
    vendor_parameters[:vendor_tds_rates_attributes].each_with_index do |vtra, index|
      unless vtra[:tds_rates_list_id].present?
        vendor_parameters[:vendor_tds_rates_attributes].delete_at(index)
      end
    end

    if user.company_id == 156

      unless vendor_parameters[:pan].present?
        add_message :error, "Please provide PAN to proceed"
        return
      else
        validate_attachment(vendor_parameters, :pan)
      end

      # Remove Empty gstin locations
      vendor_parameters[:gstin_locations_attributes].each_with_index do |gst, index|
        unless gst.keys.present?
          vendor_parameters[:gstin_locations_attributes].delete_at(index)
        end
      end


      if vendor_parameters[:msme_registered].present? && (vendor_parameters[:msme_registered] == 1 || vendor_parameters[:msme_registered] == '1')
        validate_attachment(vendor_parameters, :msme_certificate)
      end

      if vendor_parameters[:gst_registered].present? && (vendor_parameters[:gst_registered] == 1 || vendor_parameters[:gst_registered] == '1')
        validate_attachment(vendor_parameters, :gstin)
        validate_gstin(vendor_parameters)
        # validate_business_name(vendor_parameters)
        # validate_pan(vendor_parameters)
      end
    end
  end

  def pre_process
    # here if the account number being added already exists, update the particular record and
    # don't create a new account
    vendor_parameters[:bank_accounts_attributes]&.each_with_index do |bank_account, index|
      # ba = BankAccount.find_by(account_number: bank_account[:account_number], account_owner_type)
      ba = user.company.bank_accounts.find_by(account_number: bank_account[:account_number], account_owner_type: "YesBankVendor")
      if ba.present?
        existing_vendor = ba.account_owner
        next if existing_vendor.id == self.vendor.id
        if existing_vendor.authorized
          add_message :error, "Bank account number #{ba.account_number} already belongs to vendor - #{existing_vendor.business_name} - #{existing_vendor.vendor_id}"
          break
        end          
        # vendor_parameters[:bank_accounts_attributes][index][:id] = ba.id
      end
    end

    # checking for attachments and adding the id
    # if self.vendor_parameters&.dig(:vendor_attachments_attributes)
    #   # only if the actual attached file is present, do you even make it save
    #   if self.vendor_parameters[:vendor_attachments_attributes].first[:attached_file].present?
    #     if self.vendor.vendor_attachments.present?
    #       self.vendor_parameters[:vendor_attachments_attributes].first[:id] = self.vendor.vendor_attachments.first&.id
    #     end
    #     self.vendor_parameters[:vendor_attachments_attributes].first.delete(:remove_file)
    #   elsif self.vendor_parameters[:vendor_attachments_attributes].first[:remove_file] == '1'
    #     self.vendor_parameters[:vendor_attachments_attributes].first[:_destroy] = true
    #     self.vendor_parameters[:vendor_attachments_attributes].first[:id] = self.vendor.vendor_attachments.first&.id
    #     self.vendor_parameters[:vendor_attachments_attributes].first.delete(:remove_file)
    #   else
    #     if self.vendor.vendor_attachments.present?
    #       self.vendor_parameters[:vendor_attachments_attributes].first.delete(:remove_file)
    #     else
    #       self.vendor_parameters.delete(:vendor_attachments_attributes)
    #     end
    #   end
    # end

    if self.vendor_parameters&.dig(:vendor_attachments_attributes)

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