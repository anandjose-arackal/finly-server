class Vendors::Base < BaseOperation
  attr_accessor :vendor, :workflow_output, :company

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    self.company = user.company
    # id = params[:vendor_id] || params[:yes_bank_vendor_id] || params[:id] 
    self.vendor = Vendors::Show.(user, params).vendor
  end

  def validate
    unless self.vendor.present?
      add_message :error, "Vendor not found"
    end
  end


  protected

  def vendor_attributes
    params.require(:vendor).permit(:name, :email, :mobile_number, :authorized, :description, :pan, :tin, :gst, :state, :state_code_id, :gst_registered, :vendor_type_id,
                                   :msme_registered, :msme_registration_number, :rcm_enabled,
                                   :business_name, :trade_name, :address, :payment_term_id, :currency_id, :policy_id, :vendor_id, :override_vendor_id,
                                   vendor_tds_rates_attributes: [:id, :tds_rates_list_id, :_destroy],
                                   bank_accounts_attributes: [:id, :account_number, :confirm_account_number, :ifsc, :name, :default_account, :bank_account_master_id, :_destroy, :disabled],
                                   vendor_attachments_attributes: [:id, :attached_file, :attachment_type, :_destroy],
                                   gstin_locations_attributes: [:id, :gstin_id, :gstin, :location, :state_id, :poc_name, :poc_email, :poc_mobile_number, :poc_fax, :poc_designation, :address, :_destroy]
    )
  end

  def validate_custom_fields(reset_fields = false)
    if self.vendor.valid?
      set_fields = set_custom_fields false, reset_fields
      unless set_fields.success?
        add_message :error, set_fields.messages[:error]
        return
      end
      valid = CustomField::Validate.(self.vendor)
      unless valid.success?
        add_message :error, valid.messages[:error]
        return
      end
    end
  end

  def set_custom_fields(save, reset_fields = false)
    custom_fields = {custom_fields: (params[:custom_fields] or params&.dig(:vendor, :custom_fields))}
    custom_fields[:user] = user
    custom_fields[:reset_fields] = reset_fields
    custom_fields[:save] = save
    CustomField::SetFields.(self.vendor, FieldParentType.id_for(:yes_bank_vendor), custom_fields)
  end

  # def validate_business_name(vendor_params)
  #   business_name = vendor_params[:business_name]
  #   vendor_params[:gstin_locations_attributes].each_with_index do |gstin_location, index|
  #     gstin = gstin_location[:gstin]

  #     unless gstin.present?
  #       add_message :error, "Please Provide GSTIN for Location #{index+1}"
  #       next
  #     end

  #     gstin_master = Gstin.with_gstin(gstin).first

  #     if gstin_master.present?
  #       match_percentile = fuzzy_string_match(business_name, gstin_master.legal_name_of_business)

  #       if match_percentile < 90
  #         add_message :error, "Business Name Match Percentile is below 90% for Location #{index+1}"
  #       end
  #     end
  #   end
  # end

  def validate_gstin(vendor_params)
    business_name = vendor_params[:business_name]
    return if vendor_params[:gstin_locations_attributes].blank?
    vendor_params[:gstin_locations_attributes].each_with_index do |gstin_location, index|
      gstin = gstin_location[:gstin]

      unless gstin.present?
        add_message :error, "Please Provide GSTIN for Location #{index + 1}"
        next
      end

      gstin_master = Gstin.with_gstin(gstin).first

      if gstin_master.present?
        gstin_location[:gstin_id] = gstin_master.id
        if gstin_master.status == "Active"

          unless gstin_master.gstin.slice(2, 10) == vendor_params[:pan]&.upcase
            add_message :error, "PAN doesn't match with GSTIN for Location #{index + 1}"
          end

          match_percentile = StringUtils.fuzzy_string_match(StringUtils.clear_generic_keywords(business_name), StringUtils.clear_generic_keywords(gstin_master.legal_name_of_business))
          trade_name_match_percentile = StringUtils.fuzzy_string_match(StringUtils.clear_generic_keywords(business_name), StringUtils.clear_generic_keywords(gstin_master.trade_name))

          if match_percentile < 60 && trade_name_match_percentile < 60
            add_message :error, "Business Name or Trade Name Match Percentile is below 60% for Location #{index + 1}"
          end
        else
          add_message :error, "GSTIN Status is not Active for Location #{index + 1}"
        end
      end
    end
  end

  def validate_attachment(vendor_params, type)
    # Checks presence of attachment with passed type
    types = {pan: "PAN", gstin: "GSTIN Certificate", cancelled_cheque: "Cancelled Cheque", tax_exemption: "Tax Exemption Certificate", lower_exemption: "Lower Exemption Certificate", msme_certificate: "MSME Certificate", others: "Others"}

    # attachment_name = 
    if vendor_params.present? && vendor_params[:vendor_attachments_attributes].present?
      unless (self.vendor.present? && self.vendor.vendor_attachments.with_type(type).present?) || find_attachment(vendor_params[:vendor_attachments_attributes], type)
        # do nothing
        # elsif
        #   add_message :error, "Please upload #{types[type]}"
        # else
        add_message :error, "Please upload #{types[type]}"
      end
    elsif self.vendor.present? && self.vendor.vendor_attachments.with_type(type).present?
      # do nothing
    else
      add_message :error, "Please upload #{types[type]}"
    end
  end

  def find_attachment(attachment_params, type)
    found = false
    attachment_params.each do |attachment|
      if attachment[:attachment_type] == type.to_s && !(attachment[:_destroy].present?)
        found = true
        break
      end
    end
    found
  end

  def decode_base64_file(file, string)
    return false if (file.blank? or string.blank?)
    file_data = string[string.index("base64,") + "base64,".size, string.size]
    adapter = Paperclip.io_adapters.for(string)
    ext =  Rack::Mime::MIME_TYPES.invert[adapter.content_type]
    name = file[:name].present? ? file[:name] : "data"
    name = name.to_s + Time.now.to_i.to_s + SecureRandom.hex(10).to_s
    file_name = name + ext.to_s
    file_path = "tmp/#{file_name}"
    File.open(file_path, 'wb') { |f| f.write(Base64.decode64(file_data)) }
    file[:attached_file] = File.new(file_path, 'r')
  end

  def validate_pan_number_in_gstin(pan_number=nil, gstin=nil, gst_registered=nil)
    if pan_number.present? && gstin.present? && (gst_registered != "0")
      pan_number_from_gstin = gstin[2..gstin.length - 4].to_s&.upcase
      unless pan_number.to_s&.upcase == pan_number_from_gstin
        add_message :error, "Pan number #{pan_number} does not match with gstin pan #{pan_number_from_gstin}"
        return false
      end
    end
    true
  end

  def validate_duplicate_bank_account
    if vendor.present? && vendor.is_a?(YesBankVendor)
      if self.vendor.bank_accounts.present?
        account_numbers = self.vendor.bank_accounts.map(&:account_number)
        duplicate_account_numbers = account_numbers.select{|item| account_numbers.count(item) > 1}.uniq
        if duplicate_account_numbers.present?
          add_message :error, "Duplicate records found for account numbers #{duplicate_account_numbers.join(', ')}"  
        end
        # if user.company.bank_accounts.where(account_number: account_numbers).where.not(account_owner_id: vendor.id, account_owner_type: 'YesBankVendor').present?
        #   associated_account_numbers = user.company.bank_accounts.where(account_number: account_numbers).where.not(account_owner_id: vendor.id, account_owner_type: 'YesBankVendor').pluck(:account_number)
        #   add_message :error, "Account number: #{associated_account_numbers.join(', ')}  already in use"
        # end
      end
    end
  end

  def validate_default_bank_account
    unless vendor.bank_accounts.collect(&:default_account).include?(true)
      add_message :error, "Please set one bank account as default"
    end
  end

end