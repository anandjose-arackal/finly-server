class Vendors::Update < Vendors::Base

  attr_accessor :vendor, :vendor_parameters, :vendor_changes

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
    self.vendor_changes = {}

    # Remove policy id from vendor params if present, as updating a vendor doesn't go through approval again
    # self.vendor_parameters.delete(:policy_id)
    self.vendor = Vendors::Show.(user, params).vendor rescue nil
  end

  def validate
    if vendor.blank?
      add_message :error, "Vendor not found"
      return
    end
    if self.vendor_parameters[:policy_id].present? && self.vendor_parameters[:policy_id]&.to_i != vendor.policy_id
      unless vendor.created_by_id == user.id && YesBankVendor.status_ids(:retracted, :rejected, :draft).include?(vendor.status_id)
        add_message :error, "Unable to update policy at this state"
        return       
      end
    end


    unless (user.is_vendor_manager? || user.vendor_payment_admin?) || (vendor.created_by_id == user.id && YesBankVendor.status_ids(:retracted, :draft, :rejected).include?(vendor.status_id)) || (vendor.get_reviewers.include?(user) && vendor.awaiting_approval?)
      add_message :error, "You do not have permission for this action"
      return
    end

    # Remove tds from vendor params if tds_rates_list_id is blank
    if vendor_parameters[:vendor_tds_rates_attributes].present?
      vendor_parameters[:vendor_tds_rates_attributes].each_with_index do |vtra, index|
        unless vtra[:tds_rates_list_id].present?
          vendor_parameters[:vendor_tds_rates_attributes].delete_at(index)
        end
      end
    end

    if self.vendor.pan.blank? and self.vendor_parameters[:pan].blank?
      # vendor_parameters[:gstin_locations_attributes] = []
      vendor_parameters[:gstin_locations_attributes].each do |gstin|
        gstin[:gstin] = nil
        gstin[:gstin_id] = nil
      end
      add_message :notice, "GSTIN details can only be saved if a valid PAN is supplied."
    end

    if vendor_parameters[:gstin_locations_attributes].present?
      vendor_parameters[:gstin_locations_attributes].each do |gstin_location|
        poc_email = gstin_location[:poc_email]
        poc_mobile_number = gstin_location[:poc_mobile_number]
        if poc_email.present?
          unless Constants::VALID_EMAIL_FORMAT.match?(poc_email)
            add_message :error, "#{poc_email}: Invalid email"
            return
          end
        end

        if poc_mobile_number.present?
          unless Constants::VALID_MOBILE_NUMBER.match?(poc_mobile_number)
            add_message :error, "#{poc_mobile_number}: Invalid mobile number"
            return
          end
        end
      end
    end


    # # TODO - check if this is required for all companies
    # # unless user.company_id == 156
    # unless [156, 205, 206, 207, 208, 2, 1].include?(user.company_id)
    #   if vendor_parameters[:pan].blank?
    #     add_message :error, 'Please provide PAN to proceed'
    #     return
    #   end
    #   unless vendor_parameters[:pan].match?(Constants::VALID_PAN)
    #     add_message :error,  "Incorrent format for pan number: #{vendor_parameters[:pan]}"
    #     return
    #   end
    #
    # end

    if vendor_parameters[:pan].present?
      unless vendor_parameters[:pan].match?(Constants::VALID_PAN)
        add_message :error,  "Incorrent format for pan number: #{vendor_parameters[:pan]}"
      end
      validate_attachment(vendor_parameters, :pan)
    end


    if [156, 179, 205, 206, 207, 208, 2, 1].include?(user.company_id)


      # Remove Empty gstin locations
      if vendor_parameters[:gstin_locations_attributes].present?
        vendor_parameters[:gstin_locations_attributes].each_with_index do |gst, index|
          unless gst.keys.present?
            vendor_parameters[:gstin_locations_attributes].delete_at(index)
          end
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

    if self.vendor_parameters[:bank_accounts_attributes].blank?
      add_message :error, "Please provide bank account details"
      return
    end

    if self.vendor_parameters[:bank_accounts_attributes].present?
      # check to see the number of bank account sent is equal to the bank account marked for destruction
      ba_count = self.vendor_parameters[:bank_accounts_attributes].count
      ba_delete_count = self.vendor_parameters[:bank_accounts_attributes].select {|b| b[:_destroy] == true}.count
      if ba_count == ba_delete_count
        add_message :error, "Please provide bank account details"
        return
      end
    end

    if self.vendor_parameters[:bank_accounts_attributes].present?
      self.vendor_parameters[:bank_accounts_attributes].each do |bank_account|
        if bank_account[:account_number].present? && bank_account[:confirm_account_number].present? && (bank_account[:account_number] != bank_account[:confirm_account_number])
          add_message :error, "Account number: #{bank_account[:account_number]} does not match with confirmation account number: #{bank_account[:confirm_account_number]}"
          return
        end
      end
    end

    # checking for duplicates within this particular company
    current_company_vendors = user.company.yes_bank_vendors.non_deleted
    if self.vendor_parameters[:vendor_id].blank?
      self.vendor_parameters[:vendor_id] = self.vendor.vendor_id
    end
    vendor_id = self.vendor_parameters[:vendor_id]
    duplicate_vendors = current_company_vendors.filter_vendor_id(vendor_id).without_id(self.vendor.id)
    if vendor_id.present? && duplicate_vendors.present?
      add_message :error, "There is a similar vendor added with the same vendor ID in our records."
      return
    end

    if YesBankVendor.status_ids(:retracted, :draft, :rejected).exclude?(vendor.status_id) and self.vendor_parameters[:bank_accounts_attributes].present?
      self.vendor_parameters[:bank_accounts_attributes].delete(:_destroy)
    end
  end

  def pre_process
    # here if the account number being added already exists, update the particular record and
    # don't create a new account
    # vendor_parameters[:bank_accounts_attributes]&.each_with_index do |bank_account, index|
    #   # ba = BankAccount.find_by(account_number: bank_account[:account_number], account_owner_type)
    #   ba = user.company.bank_accounts.find_by(account_number: bank_account[:account_number], account_owner_type: "YesBankVendor")
    #   if ba.present?
    #     existing_vendor = ba.account_owner
    #     next if existing_vendor.id == self.vendor.id
    #     if existing_vendor.authorized
    #       add_message :error, "Bank account number #{ba.account_number} already belongs to vendor - #{existing_vendor.business_name} - #{existing_vendor.vendor_id}"
    #       break
    #     end          
    #     # vendor_parameters[:bank_accounts_attributes][index][:id] = ba.id
    #   end
    # end

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

    self.vendor_parameters.delete(:override_vendor_id)

    if vendor_parameters&.dig(:vendor_attachments_attributes).present?
      vendor_parameters[:vendor_attachments_attributes].each do |file|
        decode_base64_file(file, file[:attached_file])
      end
    end
  end

  def process
    validate_custom_fields(false)
    return if has_errors?
    
    vendor.assign_attributes(vendor_parameters)
    validate_gstin_pan_number
    return if has_errors?
    validate_duplicate_bank_account
    validate_default_bank_account
    return if has_errors?
    if vendor.valid?
      self.vendor_changes = detect_changes_in_vendor(vendor) # sends mail if bank accounts added or updated
      if all_bank_accounts_disabled?
        add_message :error, "Atleast one bank account needs to be enabled. Otherwise, please deactivate this vendor."
        return false
      end

      validate_mark_for_destruction_account
      return if has_errors?
      
      vendor.save
      add_message :success, "Vendor updated"
    else
      add_message :error, vendor.errors.full_messages
    end

    # unless vendor.update(vendor_parameters)
    #   add_message :error, vendor.errors.full_messages
    # end
  end

  def post_process
    if self.vendor_changes[:bank_account_changed].present?
      Event::EVendors::Update.(user, {document: self.vendor, vendor_changes: self.vendor_changes})
    end
  end

  private

  def detect_changes_in_vendor(vendor)
    return {} if vendor.bank_accounts.blank?
    {
      bank_account_changed: vendor.bank_accounts.map {|v| v.changes_to_save if v.changes_to_save.present?}.compact,
      bank_accounts: vendor.bank_accounts.map {|v| v.changes_to_save}
    }
  end

  def validate_gstin_pan_number
    location_gstins = self.vendor.gstin_locations.map(&:gstin).flatten.compact
    return true if !self.vendor.gst_registered || self.vendor.pan.blank? || location_gstins.blank?
    validated = false
    self.vendor.gstin_locations.each do |vendor_location|
      validated = validate_pan_number_in_gstin(vendor.pan, vendor_location.gstin, vendor.gst_registered)
      unless validated
        add_message :error, "Pan number in gstin for location #{vendor_location.location} is incorrect"
        break
      end
    end
    validated
  end

  def validate_mark_for_destruction_account
    mark_for_deletion_accounts = self.vendor.bank_accounts.collect{|b| b if b.marked_for_destruction? or b.disabled}.compact
    if mark_for_deletion_accounts.present?
      if user.company.purchase_orders.filter_payable_advances.where(bank_account_id: mark_for_deletion_accounts.pluck(:id)).present? || user.company.inward_invoices.filter_payable_invoices(true).where(bank_account_id: mark_for_deletion_accounts.pluck(:id)).present? || user.company.beneficiary_payments.only_unpaid.where(bank_account_id: mark_for_deletion_accounts.pluck(:id)).present? || Payment.where(company_id: user.company_id, payment_status_id: PaymentStatus.status_ids_for_invoice_initiated, receiving_account_id: mark_for_deletion_accounts.pluck(:id)).present?
        add_message :error, "Cannot delete or disable bank account with account number, #{mark_for_deletion_accounts.pluck(:account_number).join(', ')} as they are already in use"
      end
    end
  end

  def all_bank_accounts_disabled?
    self.vendor.bank_accounts.all? {|account| account.disabled }
  end


end
